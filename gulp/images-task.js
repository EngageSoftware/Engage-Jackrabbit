/*eslint-env node*/
/*eslint no-console:0*/
'use strict';

const gulp = require('gulp');
const debug = require('gulp-debug');
const gulpif = require('gulp-if');
const shell = require('gulp-shell');
const imagemin = require('gulp-imagemin');
const gitignoreFilter = require('./gitignore-filter');
const errorHandler = require('./errorHandler');

const maximumOptimizationLevel = 7;

module.exports = function imagesTask(project, args) {
    const developmentBuild = args.developmentBuild;
    const imagesStream = gulp.src(project.imageFileGlobs)
                             .pipe(errorHandler(args))
                             .pipe(gitignoreFilter.filterStream())
                             .pipe(gulpif(args.debug, debug({ title: `${project.name}-images:`, })));
    if (developmentBuild) {
        // do nothing to images during development
        return imagesStream;
    }

    return imagesStream.pipe(shell([ 'attrib -r "<%= file.path %>"', ])) // remove readonly attribute, since we're overwriting the image
                       .pipe(imagemin({
                           optimizationLevel: maximumOptimizationLevel,
                           progressive: true,
                           interlaced: true,
                           svgoPlugins: [ { removeViewBox: false, }, { removeUselessDefs: false, }, ],
                        }))
                        .pipe(gulp.dest(project.path));
};
