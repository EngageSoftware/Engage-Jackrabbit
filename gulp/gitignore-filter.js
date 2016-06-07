/*eslint-env node*/
/*eslint no-console:0*/
'use strict';

const fs = require('fs');
const path = require('path');
const ignore = require('ignore');
const filter = require('gulp-filter');

const gitignore = ignore();
if (fs.existsSync('.gitignore')) {
    gitignore.add(fs.readFileSync('.gitignore').toString());
}

const gitignoreFilter = gitignore.createFilter();

module.exports = {
    filter: gitignoreFilter,
    filterStream: function filterStream() {
        return filter((file) => gitignoreFilter(path.relative(process.cwd(), file.path)));
    },
};
