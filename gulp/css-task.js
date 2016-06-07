/*eslint-env node*/
/*eslint no-console:0*/
'use strict';

const gulp = require('gulp');
const filter = require('gulp-filter');
const debug = require('gulp-debug');
const gulpif = require('gulp-if');
const postcss = require('gulp-postcss');
const postcssReporter = require('postcss-reporter');
const stylelint = require('stylelint');
const lessSyntax = require('postcss-less');
const less = require('gulp-less');
const autoprefixer = require('autoprefixer');
const sourcemaps = require('gulp-sourcemaps');
const cssnano = require('gulp-cssnano');
const bless = require('gulp-bless');
const browserSync = require('browser-sync');
const mergeStream = require('merge-stream');
const gitignoreFilter = require('./gitignore-filter');
const errorHandler = require('./errorHandler');

module.exports = function cssTask(project, args) {
    const developmentBuild = args.developmentBuild;

    const lintFiles = postcss([ stylelint, postcssReporter({ clearMessages: true, }), ], { syntax: lessSyntax, });
    const lintStream = gulp.src(project.lessFilesGlobs)
                           .pipe(errorHandler(args))
                           .pipe(gitignoreFilter.filterStream())
                           .pipe(gulpif(args.debug, debug({ title: `${project.name}-css-lint:`, })))
                           .pipe(gulpif(developmentBuild, lintFiles));

    const autoprefixerReporter = postcssReporter({ clearMessages: true, });
    const compileStream = gulp.src(project.lessEntryFilesGlobs)
                              .pipe(errorHandler(args))
                              .pipe(gitignoreFilter.filterStream())
                              .pipe(gulpif(args.debug, debug({ title: `${project.name}-css:`, })))
                              .pipe(gulpif(developmentBuild, sourcemaps.init()))
                              .pipe(less())
                              .pipe(postcss([ autoprefixer(), autoprefixerReporter, ]))
                              .pipe(gulpif(!developmentBuild, cssnano({ safe: true, })))
                              .pipe(gulpif(developmentBuild, sourcemaps.write('.')))
                              .pipe(gulpif(!developmentBuild, bless()))
                              .pipe(gulp.dest(project.stylesOutputDirPath))
                              .pipe(filter('**/*.css')) // don't pass source-map files to browser sync
                              .pipe(gulpif(developmentBuild, browserSync.reload({ stream: true, })));

    return mergeStream(lintStream, compileStream);
};
