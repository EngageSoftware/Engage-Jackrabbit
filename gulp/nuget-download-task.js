/*eslint-env node*/
/*eslint no-console:0*/
'use strict';

const fs = require('fs');
const request = require('request');

// based on example from https://github.com/mckn/gulp-nuget
module.exports = function nugetDownloadTask(args, done) {
    fs.access('nuget.exe', (cannotAccess) => {
        if (!cannotAccess) {
            if (args.verbose) {
                console.log('[nuget-download]', 'nuget.exe already exists');
            }

            done();
            return;
        }

        request.get('https://nuget.org/nuget.exe')
               .pipe(fs.createWriteStream('nuget.exe'))
               .on('close', done);
    });
};
