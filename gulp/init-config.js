/*eslint-env node*/
/*eslint no-console:0*/
'use strict';

const fsExtra = require('fs-extra');

module.exports = function initConfig() {
    try {
        fsExtra.copySync('./gulp/gulpfile.user.default.js', './gulpfile.user.js', { clobber: false, });
    } catch (err) {
        // file already exists
    }
};
