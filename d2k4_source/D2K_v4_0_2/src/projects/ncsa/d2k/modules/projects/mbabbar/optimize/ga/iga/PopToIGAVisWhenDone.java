
package ncsa.d2k.modules.projects.mbabbar.optimize.ga.iga;


import ncsa.d2k.core.modules.*;
import ncsa.d2k.modules.core.datatype.table.*;
import ncsa.d2k.modules.core.optimize.ga.*;
import ncsa.d2k.modules.core.optimize.ga.emo.*;

/**
	Converts the population to a table where each column is an attribute, objective value,
	or fitness.
*/
public class PopToIGAVisWhenDone extends ncsa.d2k.core.modules.DataPrepModule {

	/**
		This pair returns the description of the various inputs.
		@return the description of the indexed input.
	*/
	public String getInputInfo(int index) {
		switch (index) {
			case 0: return "      This is the population to plot.   ";
			default: return "No such input";
		}
	}

	/**
		This pair returns an array of strings that contains the data types for the inputs.
		@return the data types of all inputs.
	*/
	public String[] getInputTypes() {
		String[] types = {"ncsa.d2k.modules.projects.mbabbar.optimize.ga.IGANsgaPopulation"};
		return types;
	}

	/**
		This pair returns the description of the outputs.
		@return the description of the indexed output.
	*/
	public String getOutputInfo(int index) {
		switch (index) {
			case 0: return "The <i>IGA NSGA Population</i>.";
                        case 1: return "      This table just contains the objective values for each of the individuals in the first non-dominated front.   ";
                        default: return "No such output";
		}
	}

	/**
		This pair returns an array of strings that contains the data types for the outputs.
		@return the data types of all outputs.
	*/
	public String[] getOutputTypes() {
		String[] types = {"ncsa.d2k.modules.projects.mbabbar.optimize.ga.iga.IGANsgaPopulation",
                "ncsa.d2k.modules.core.datatype.table.basic.TableImpl"};
		return types;
	}

	/**
		This pair returns the description of the module.
		@return the description of the module.
	*/
	public String getModuleInfo() {
		return "<html>  <head>      </head>  <body>    This module converts a GA populations objective values into a table     and initiates IGA session.  </body></html>";
	}

	/**
		PUT YOUR CODE HERE.
	*/
	public void doit() throws Exception {
		IGANsgaPopulation pop = (IGANsgaPopulation) this.pullInput (0);
		if (pop.isDone ()) {
			Table vt = pop.getTable ();
                        this.pushOutput (pop,0);
			this.pushOutput (vt, 1);
		}
	}


	/**
	 * Return the human readable name of the module.
	 * @return the human readable name of the module.
	 */
	public String getModuleName() {
		return "IGA Objectives To VT";
	}

	/**
	 * Return the human readable name of the indexed input.
	 * @param index the index of the input.
	 * @return the human readable name of the indexed input.
	 */
	public String getInputName(int index) {
		switch(index) {
			case 0:
				return "Population";
			default: return "NO SUCH INPUT!";
		}
	}

	/**
	 * Return the human readable name of the indexed output.
	 * @param index the index of the output.
	 * @return the human readable name of the indexed output.
	 */
	public String getOutputName(int index) {
		switch(index) {
			case 0:
				return "IGA NSGA Population";
                        case 1:
				return "output table";
			default: return "NO SUCH OUTPUT!";
		}
	}
}

