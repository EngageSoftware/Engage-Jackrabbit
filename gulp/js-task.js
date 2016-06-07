/*eslint-env node*/
/*eslint no-console:0*/
'use strict';

const gulp = require('gulp');
const debug = require('gulp-debug');
const gulpif = require('gulp-if');
const rename = require('gulp-rename');
const jscs = require('gulp-jscs');
const eslint = require('gulp-eslint');
const babel = require('gulp-babel');
const uglify = require('gulp-uglify');
const sourcemaps = require('gulp-sourcemaps');
const gitignoreFilter = require('./gitignore-filter');
const errorHandler = require('./errorHandler');

module.exports = function jsTask(project, args) {
    const developmentBuild = args.developmentBuild;
    return gulp.src(project.javaScriptFilesGlobs)
               .pipe(errorHandler(args))
               .pipe(gitignoreFilter.filterStream())
               .pipe(gulpif(args.debug, debug({ title: `${project.name}-js:`, })))
               .pipe(gulpif(developmentBuild, sourcemaps.init()))
               .pipe(jscs(args.jscs))
               .pipe(jscs.reporter())
               .pipe(eslint(args.eslint))
               .pipe(eslint.format())
               .pipe(eslint.failOnError())
               .pipe(babel())
               .pipe(uglify())
               .pipe(rename({ suffix: '.min', }))
               .pipe(gulpif(developmentBuild, sourcemaps.write('.')))
               .pipe(gulp.dest(project.path));
};
