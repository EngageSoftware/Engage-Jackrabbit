/*eslint-env node*/
/*eslint no-console:0*/
'use strict';

const path = require('path');
const _ = require('lodash');
const glob = require('glob');
const Project = require('./Project');
const gitignoreFilter = require('./gitignore-filter');
const configOptions = require('../gulpfile.config');

module.exports = function processProjects() {
    const projectFolders = glob.sync('**/*.dnn', { nocase: true, })
        .filter(gitignoreFilter.filter)
        .map((dnnFile) => path.dirname(dnnFile));
    const moduleProjects = projectFolders
        .map((moduleFolder) => {
        const folderName = path.basename(moduleFolder);
        const moduleProject = new Project(
            `${folderName}-module`,
            moduleFolder,
            { stylesDirPath: moduleFolder, });
        moduleProject.lessEntryFilesGlobs = [ path.join(moduleFolder, '**/module.less'), ];
        const testScriptsGlob = path.join(moduleFolder, '*.Tests/Scripts/**/*.js');
        moduleProject.javaScriptFilesGlobs.push(`!${testScriptsGlob}`);
        const nugetScriptsGlob = path.join(moduleFolder, 'packages/**/*.js');
        moduleProject.javaScriptFilesGlobs.push(`!${nugetScriptsGlob}`);
        return moduleProject;
    });

    return require('../gulpfile.user').customizeProjects(
        configOptions.customizeProjects(moduleProjects));
};
