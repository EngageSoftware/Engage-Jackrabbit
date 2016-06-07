/*eslint-env node*/
/*eslint no-console:0*/
'use strict';

const path = require('path');
const _ = require('lodash');
const gulp = require('gulp');
const debug = require('gulp-debug');
const gulpif = require('gulp-if');
const rename = require('gulp-rename');
const elm = require('gulp-elm');
const uglify = require('gulp-uglify');
const shell = require('gulp-shell');
const temp = require('temp');
const vinylPaths = require('vinyl-paths');
const del = require('del');
const gitignoreFilter = require('./gitignore-filter');
const errorHandler = require('./errorHandler');

const forceDel = _.partialRight(del, { force: true, });
const elmMake = 'node_modules/.bin/elm-make.cmd';

module.exports = {
    init: function initElm() {
        return elm.init({ elmMake, });
    },

    build: function buildElm(project, args) {
        const developmentBuild = args.developmentBuild;
        return gulp.src(project.elmEntryFilesGlobs)
                   .pipe(errorHandler(args))
                   .pipe(gitignoreFilter.filterStream())
                   .pipe(gulpif(args.debug, debug({ title: `${project.name}-elm-build:`, })))
                   .pipe(elm.bundle('elm.js', { elmMake, warn: developmentBuild, }))
                   .pipe(uglify())
                   .pipe(rename({ suffix: '.min', }))
                   .pipe(gulp.dest(project.path));
    },

    test: function testElm(project, args) {
        const developmentBuild = args.developmentBuild;
        const nodePath = process.execPath;
        const tempPath = path.dirname(temp.path());
        return gulp.src(project.elmTestFilesGlobs)
                   .pipe(errorHandler(args))
                   .pipe(gitignoreFilter.filterStream())
                   .pipe(gulpif(args.debug, debug({ title: `${project.name}-elm-test:`, })))
                   .pipe(elm({ elmMake, warn: developmentBuild, }))
                   .pipe(rename({ basename: path.basename(temp.path({ suffix: '.js', })), }))
                   .pipe(gulp.dest(tempPath))
                   .pipe(shell([ `"${nodePath}" "<%= file.path %>"`, ], { verbose: args.verbose, }))
                   .pipe(vinylPaths(forceDel));
    },
};
