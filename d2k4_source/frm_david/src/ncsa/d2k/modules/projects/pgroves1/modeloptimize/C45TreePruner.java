package ncsa.d2k.modules.projects.pgroves.modeloptimize;

import ncsa.d2k.core.modules.*;


import ncsa.d2k.modules.core.datatype.table.*;
import ncsa.d2k.modules.core.prediction.decisiontree.*;

import java.util.*;

/**
 * Implements pruning of C4.5 decision trees.  The error is estimated at each
 * node using the training data.  A confidence level of 25% is used.
 * <br><br>
 * Each non-leaf node in the tree is examined for pruning.  One of two types of
 * pruning can be attempted: subtree replacment or subtree raising.  Subtree
 * replacement can occur when all the children of a node are leaves.  If the
 * error of the leaves is less than the error at the node, the node will be
 * replaced with a leaf.  Subtree raising can occur when the children of a node
 * are not all leaves.  The branch with the most training examples is temporarily
 * raised, and if the error induced after the raising is less than the error
 * of the original node, the replacement is left intact.
 * <br><br>
 * The pruning process can be time-intensive.  Each time a possible pruning
 * is tested, the new, pruned tree must be applied to the training dataset to
 * find an estimate of the new error.  When a possible pruning is not taken,
 * the tree is reverted to its original form, but the tree must again be applied
 * to the training dataset.
 */
public class C45TreePruner extends /*ReentrantComputeModuleOrderedReentrantModule*/ ComputeModule {

	public String[] getInputTypes() {
		String[] in = {
			"ncsa.d2k.modules.core.prediction.decisiontree.DecisionTreeNode",
			"ncsa.d2k.modules.core.datatype.table.ExampleTable"};
		return in;
	}

	public String getInputInfo(int i) {
		switch(i) {
			case(0):
				return "The training data that was used to build the decision tree.";
			case(1):
				return "The root node of the unpruned decision tree.";
			default:
				return "";
		}
	}

	public String getInputName(int i) {
		switch(i) {
			case(0):
				return "ET";
			case(1):
				return "UnprunedRoot";
			default:
				return "";
		}
	}

	public String[] getOutputTypes() {
		String[] out = {"ncsa.d2k.modules.core.prediction.decisiontree.DecisionTreeNode",
			"ncsa.d2k.modules.core.datatype.table.ExampleTable"};
		return out;
	}

	public String getOutputInfo(int i) {
		switch(i) {
			case(0):
				return "A DecisionTreeModel containing the pruned tree.";
			case(1):
				return "The input ExampleTable, unchanged.";
			default:
				return "";
		}
	}

	public String getOutputName(int i) {
		switch(i) {
			case(0):
				return "PrunedRoot";
			case(1):
				return "ET";
			default:
				return "";
		}
	}

	public String getModuleInfo() {
		return "C45TreePruner";
	}

	public String getModuleName() {
		return "C4.5TreePruner";
	}

	private DecisionTreeNode rootNode;
	private ExampleTable et;
	private DecisionTreeModel dtm;

	public void endExecution() {
		super.endExecution();
		rootNode = null;
		et = null;
		dtm = null;
	}

	public void doit() throws Exception {
		rootNode = (DecisionTreeNode)pullInput(0);
		et = (ExampleTable)pullInput(1);

		// clear
		rootNode.clear();
		// we need a decsion tree model so we can call the predict() method
		dtm = new DecisionTreeModel(rootNode, et);
		// now call the predict method.  we must predict so that we can
		// get the tallies of the correct and incorrect predictions on the
		// training data
		dtm.predict(et);

		white = new HashSet();
		gray = new HashSet();

		// now put all the nodes in the white category. they haven't been
		// seen yet
		putAllInWhite(rootNode);
		// perform a depth-first search
		DFS(rootNode);

		// clear the tallies of the tree
		rootNode.clear();
		// set training to false.
		rootNode.setTraining(false);
		// push the pruned tree out
		pushOutput(rootNode, 0);
		pushOutput(et, 1);
	}

	/**
	 * Perform a depth-first search, starting at the root.
	 * @param rt the root
	 */
	private void DFS(DecisionTreeNode rt) {
		for(int i = 0; i < rt.getNumChildren(); i++) {
			DecisionTreeNode dtn = rt.getChild(i);
			if(white.contains(dtn)) {
				DFSvisit(dtn);
			}
		}
		visit(rt);
	}

	/**
	 *
	 * @param rt
	 */
	private void DFSvisit(DecisionTreeNode rt) {
		white.remove(rt);
		gray.add(rt);

		for(int i = 0; i < rt.getNumChildren(); i++) {
			DecisionTreeNode dtn = rt.getChild(i);
			if(white.contains(dtn)) {
				DFSvisit(dtn);
			}
		}
		visit(rt);
	}

	/**
	 * Visit a node.  The pruning operations are done here.
	 * @param rt the root
	 */
	private void visit(DecisionTreeNode node) {
		gray.remove(node);

		// we cannot prune a leaf, only a node
		if(node.isLeaf())
			return;
		else {
			// we will calculate the error estimation for the current node
			double originalNodeErrorEstimate = errorEstimate((double)(node.getTotal()),
				(double)(node.getNumIncorrect()), Z);

			// now we must replace this node by the branch with the most
			// training examples and recalculate the error

			// find the child with the most training examples
			DecisionTreeNode cd = node.getChildWithMostTrainingExamples();

			// now find which branch of our parent that node represents
			DecisionTreeNode parent = node.getParent();
			if(parent != null) {
				// find the index of node
				int idx = -1;
				String lbl = null;

				for(int i = 0; i < parent.getNumChildren(); i++) {
					DecisionTreeNode cld = (DecisionTreeNode)parent.getChild(i);
					if(cld == node) {
						idx = i;
						if(parent instanceof CategoricalDecisionTreeNode)
							lbl = ((CategoricalDecisionTreeNode)parent).getSplitValues()[i];
						else
							lbl = parent.getBranchLabel(i);
						break;
					}
				}

				// find the index of the child to node
				int cdIdx = -1;
				String cdLabel = null;

				DecisionTreeNode prt = cd.getParent();
				for(int i = 0; i < prt.getNumChildren(); i++) {
					DecisionTreeNode c = prt.getChild(i);
					if(c == cd) {
						cdIdx = i;
						if(prt instanceof CategoricalDecisionTreeNode)
							cdLabel = ((CategoricalDecisionTreeNode)prt).getSplitValues()[i];
						else
							cdLabel = prt.getBranchLabel(i);
						break;
					}
				}

				// do the replacement, clear, re-do predict.
				parent.setBranch(idx, lbl, cd);

				rootNode.clear();
				dtm = new DecisionTreeModel(rootNode, et);
                                try{
				dtm.predict(et);
                                }catch(Exception e){}

				double replacementNodeErrorEstimate = errorEstimate((double)cd.getTotal(),
					(double)cd.getNumIncorrect(), Z);

				// if the error of the replacement is less than the error of the
				// original, leave the replacement intact.
				if(replacementNodeErrorEstimate <= originalNodeErrorEstimate) {
					;
				}
				else {
					parent.setBranch(idx, lbl, node);
					node.setBranch(cdIdx, cdLabel, cd);
					// otherwise revert to the original, unreplaced tree.

					// clear, re-do predict
					rootNode.clear();
					dtm = new DecisionTreeModel(rootNode, et);
					dtm.predict(et);
				}
			}
			// otherwise we are attempting to replace the root node.
			// node == rootNode
			else {
				// keep a temporary reference to the root node

				// perform prediction as if cd is the root
				rootNode.clear();
				dtm = new DecisionTreeModel(cd, et);
				dtm.predict(et);

				double replacementNodeErrorEstimate = errorEstimate((double)cd.getTotal(),
					(double)cd.getNumIncorrect(), Z);

				// if the replacement is less than or equal to the error of the
				// original, leave the replacement intact
				if(replacementNodeErrorEstimate <= originalNodeErrorEstimate) {
					rootNode = cd;
				}

				rootNode.clear();
				dtm = new DecisionTreeModel(rootNode, et);
				dtm.predict(et);
			}
		}
	}

	private double Z = 0.69;

	private boolean areAllChildrenLeaves(DecisionTreeNode rt) {
		for(int i = 0; i < rt.getNumChildren(); i++) {
			if(!rt.getChild(i).isLeaf())
				return false;
		}
		return true;
	}

	private HashSet white;
	private HashSet gray;

	private void putAllInWhite(DecisionTreeNode rt) {
		white.add(rt);
		for(int i = 0; i < rt.getNumChildren(); i++) {
			putAllInWhite(rt.getChild(i));
		}
	}

	// f = E/N
	// N = number of instances
	// z = 0.69

	private static double errorEstimate(double N, double E, double z) {
		double f = E/N;

		double usq = (f/N);
		usq -= (Math.pow(f, 2)/N);
		usq += (Math.pow(z, 2)/(4*Math.pow(N, 2)));

		double numerator = f + (Math.pow(z, 2)/(2*N)) + (z*Math.pow(usq, .5));
		double denominator = 1 + (Math.pow(z, 2)/N);

		return numerator/denominator;
	}
}
