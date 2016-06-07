/*eslint-env node*/
/*eslint no-console:0*/
'use strict';

const path = require('path');

module.exports = class Project {
    constructor(name, projectPath, options) { // jscs:ignore disallowAnonymousFunctions
        this.name = name;
        this.path = projectPath;

        options = options || {};
        this.imageExtensions = options.imageExtensions || [ 'jpg', 'gif', 'png', 'svg', ];
        this.imageFileGlobs = this.imageExtensions.map((ext) => path.join(projectPath, `**/*.${ext}`));
        this.stylesDirPath = options.stylesDirPath || path.join(projectPath, 'styles/');
        this.stylesOutputDirPath = options.stylesOutputDirPath || projectPath;
        this.lessEntryFilesGlobs = [ path.join(this.stylesDirPath, 'skin.less'), ];
        this.lessFilesGlobs = [ path.join(this.stylesDirPath, '**/*.less'), ];
        this.viewFilesGlobs = [ path.join(projectPath, '**/*.ascx'), ];
        this.buildFilesGlobs = [ path.join(projectPath, '**/*.build'), path.join(projectPath, '**/*.Build'), ];
        this.solutionFilesGlobs = [ path.join(projectPath, '**/*.sln'), ];
        const minifiedScriptsGlob = path.join(projectPath, '**/*.min.js');
        this.javaScriptFilesGlobs = [ path.join(projectPath, '**/*.js'), `!${minifiedScriptsGlob}`, ];
        this.elmEntryFilesGlobs = [ path.join(projectPath, '**/Main.elm'), ];
        this.elmFilesGlobs = [ path.join(projectPath, '**/*.elm'), ];
        this.elmTestFilesGlobs = [ path.join(projectPath, '**/NodeTestRunner.elm'), ];
    }
};
