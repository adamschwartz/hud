coffee     = require 'gulp-coffee'
concat  = require 'gulp-concat'
fs      = require 'fs'
gulp    = require 'gulp'
gulpif  = require 'gulp-if'
coffee  = require 'gulp-coffee'
gutil   = require 'gulp-util'
jade    = require 'gulp-jade'
nib     = require 'nib'
Path    = require 'path'
rename  = require 'gulp-rename'
stylus  = require 'gulp-stylus'

handleError = (err) ->
  gutil.log err
  gutil.beep()

  @emit 'end'


STYLUS_OPTS =
  use: [nib()]
  errors: true
  paths: [__dirname]

isCoffeeFile = (file) ->
  return true if file.path.match(/\.coffee$/)

gulp.task 'js', ->
  gulp.src(['./coffee/*.js', './coffee/*.coffee'])
    .pipe(gulpif(isCoffeeFile, coffee().on('error', handleError)))
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
