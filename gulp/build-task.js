/*eslint-env node*/
/*eslint no-console:0*/
'use strict';

const gulp = require('gulp');
const debug = require('gulp-debug');
const gulpif = require('gulp-if');
const shell = require('gulp-shell');
const msbuild = require('gulp-msbuild');
const gitignoreFilter = require('./gitignore-filter');
const errorHandler = require('./errorHandler');

module.exports = function buildTask(project, args) {
    const developmentBuild = args.developmentBuild;
    const nugetVerbosity = args.verbose ? 'detailed' : 'normal';

    return gulp.src(project.solutionFilesGlobs)
               .pipe(errorHandler(args))
               .pipe(gitignoreFilter.filterStream())
               .pipe(gulpif(args.debug, debug({ title: `${project.name}-build:`, })))
               .pipe(shell([ `nuget.exe restore "<%= file.path %>" -NonInteractive -Verbosity ${nugetVerbosity}`, ]))
               .pipe(msbuild({
                   errorOnFail: true,
                   stdout: true,
                   verbosity: args.verbose ? 'detailed' : 'minimal',
                   targets: [ 'Build', ],
                   toolsVersion: 14.0,
                   configuration: developmentBuild ? 'Debug' : 'Release',
               }));
};
