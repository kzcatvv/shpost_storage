# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
ready = ->
  $("#scan").keyup(scaned)
  

$(document).ready(ready)
$(document).on('page:load', ready)

scaned = (e) ->
  v = $('#scan').val()
  e = e || window.event
  if e.keyCode is 13    
    if scans.has(v)
      scan = scans.get(v)
      r = $("#realam_" + scan.id)
      r.val(eval(r.val()) + 1)
    $('#scan').val("")
    return false
