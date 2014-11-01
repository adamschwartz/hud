bower      = require 'gulp-bower'
browserify = require 'browserify'
buffer     = require 'gulp-buffer'
coffee     = require 'gulp-coffee'
concat     = require 'gulp-concat'
fs         = require 'fs'
gulp       = require 'gulp'
gulpif     = require 'gulp-if'
gutil      = require 'gulp-util'
jade       = require 'gulp-jade'
nib        = require 'nib'
Path       = require 'path'
rename     = require 'gulp-rename'
replace    = require 'gulp-replace'
source     = require 'vinyl-source-stream'
stylus     = require 'gulp-stylus'
uglify     = require 'gulp-uglify'

handleError = (err) ->
  gutil.log err
  gutil.beep()

  @emit 'end'

STYLUS_OPTS =
  use: [nib()]
  errors: true
  paths: [
    __dirname
    Path.join(__dirname, 'bower_components')
  ]

gulp.task 'js', ->
  gulp.src(['./coffee/**'])
    .pipe(gulpif(/[.]coffee$/, coffee().on('error', handleError)))
    .pipe(concat('index.js'))
    .pipe(gulp.dest('./js'))

gulp.task 'css', ->
  gulp.src('./styl/index.styl')
    .pipe(stylus(STYLUS_OPTS))
      .on('error', handleError)
    .pipe(rename('index.css'))
    .pipe(gulp.dest('./css'))

gulp.task 'html', ->
  gulp.src('./jade/**')
    .pipe(jade().on('error', handleError))
    .pipe(gulp.dest('./'))

gulp.task 'watch', ->
  gulp.watch ['./coffee/**'], ['js']
  gulp.watch ['./styl/**'], ['css']
  gulp.watch ['./jade/**'], ['html']

gulp.task 'default', [
  'js'
  'css'
  'html'
  'watch'
]
