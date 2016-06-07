/*eslint-env node*/
/*eslint no-console:0*/
'use strict';

const minimist = require('minimist');
const configOptions = require('../gulpfile.config');

module.exports = function processArguments() {
    const defaultOptions = require('../gulpfile.user').customizeArgs(
        configOptions.customizeArgs({
            nantPath: '',
            env: process.env.NODE_ENV || 'development',
    }));

    const argsOptions = {
      string: [ 'env', 'nantPath', 'url', ],
      'boolean': [ 'verbose', 'debug', ],
      'default': defaultOptions,
    };
    const optionsIndex = 2;
    const args = minimist(process.argv.slice(optionsIndex), argsOptions);
    args.developmentBuild = args.env !== 'production';
    return args;
};
