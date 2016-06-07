/*eslint-env node*/
/*eslint no-console:0*/
'use strict';

const _ = require('lodash');
const runSequence = require('run-sequence');
const gulp = require('gulp');
const browserSync = require('browser-sync');

const initConfig = require('./gulp/init-config');
const processArguments = require('./gulp/process-arguments');
const processProjects = require('./gulp/process-projects');
const doCssTask = require('./gulp/css-task');
const elmTasks = require('./gulp/elm-tasks');
const doJsTask = require('./gulp/js-task');
const doImagesTask = require('./gulp/images-task');
const doBuildTask = require('./gulp/build-task');
const doNugetDownloadTask = require('./gulp/nuget-download-task');
const doPackageTask = require('./gulp/package-task');

initConfig();
const args = processArguments();
const moduleProjects = processProjects();

if (args.verbose) {
    console.log('args', args);
    console.log('projects', moduleProjects);
}

gulp.task('nuget-download', (done) => doNugetDownloadTask(args, done));
gulp.task('config-init', () => initConfig());
gulp.task('elm-init', (done) => elmTasks.init(done));

moduleProjects.forEach((project) => {
    const projectName = project.name;
    gulp.task(`css:${projectName}`, () => doCssTask(project, args));
    gulp.task(`js:${projectName}`, () => doJsTask(project, args));
    gulp.task(`elm-build:${projectName}`, [ 'elm-init', ], () => elmTasks.build(project, args));
    gulp.task(`elm-test:${projectName}`, [ 'elm-init', ], () => elmTasks.test(project, args));
    gulp.task(`elm:${projectName}`, [ `elm-build:${projectName}`, `elm-test:${projectName}`, ]);
    gulp.task(`images:${projectName}`, () => doImagesTask(project, args));
    gulp.task(`build:${projectName}`, [ 'nuget-download', ], () => doBuildTask(project, args));
    gulp.task(`package:${projectName}`, [ projectName, `build:${projectName}`, ], () => doPackageTask(project, args));
    gulp.task(
        projectName,
        [
            `css:${projectName}`,
            `js:${projectName}`,
            `elm:${projectName}`,
            `images:${projectName}`,
        ]);
});

function runTasksInSequence(tasks) {
    if (_.flattenDeep(tasks).length === 0) {
        return (done) => done();
    }

    return (done) => {
        tasks.push(done);
        runSequence(...tasks);
    };
}

gulp.task('build', runTasksInSequence(moduleProjects.map((p) => `build:${p.name}`)));

const packageTasks = moduleProjects.map((p) => `package:${p.name}`);
gulp.task('package', runTasksInSequence(packageTasks));

function makeTasks(taskGroup, taskProjects) {
    const tasks = taskProjects.map((project) => project.name);
    gulp.task(taskGroup, tasks);
    gulp.task(`css:${taskGroup}`, tasks.map((taskName) => `css:${taskName}`));
    gulp.task(`js:${taskGroup}`, tasks.map((taskName) => `js:${taskName}`));
    gulp.task(`elm:${taskGroup}`, tasks.map((taskName) => `elm:${taskName}`));
    gulp.task(`elm-build:${taskGroup}`, tasks.map((taskName) => `elm-build:${taskName}`));
    gulp.task(`elm-test:${taskGroup}`, tasks.map((taskName) => `elm-test:${taskName}`));
    gulp.task(`images:${taskGroup}`, tasks.map((taskName) => `images:${taskName}`));
    gulp.task(`test:${taskGroup}`, tasks.map((taskName) => `test:${taskName}`));
}

makeTasks('modules', moduleProjects);

gulp.task('watch', [ 'default', ], () => {
    moduleProjects.forEach((project) => {
        gulp.watch(project.lessFilesGlobs, [ `css:${project.name}`, ]);
        gulp.watch(project.javaScriptFilesGlobs, [ `js:${project.name}`, ]);
        gulp.watch(project.elmFilesGlobs, [ `elm:${project.name}`, ]);
    });

    browserSync(args.browserSync);
});

gulp.task('test', moduleProjects.map((p) => `test:${p.name}`));

const defaultDependencies = moduleProjects.map((p) => p.name);
gulp.task('default', defaultDependencies);
