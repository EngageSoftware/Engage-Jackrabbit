/*eslint-env node*/
/*eslint no-console:0*/
'use strict';

module.exports = {

    /** Customize any arguments for this projects
     * @param {Array} args - The default arguments
     * @return {Array} The modified arguments
     */
    customizeArgs: (args) => args,

    /** Customize the projects
     * @param {Object[]} projects - An array of projects
     * @return {Object[]} The modified projects array
     */
    customizeProjects: (projects) => projects,
};
