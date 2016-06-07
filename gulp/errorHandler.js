/*eslint-env node*/
/*eslint no-console:0*/
'use strict';

const plumber = require('gulp-plumber');
const notify = require('gulp-notify');

module.exports = function handleStreamError(args) {
    const errorHandler = args.developmentBuild
        ? notify.onError({ title: '<%= error.plugin %> Error', message: '<%= error.message %>', })
        : false;
    return plumber({ errorHandler, });
};
