# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  $(".up-down-widget a.udw-top").click( pm_event_handler("plus") )
  $(".up-down-widget a.udw-bottom").click( pm_event_handler("minus") )

  $(".new_comment").submit ( ajax_response_submit_handler )

ajax_response_submit_handler = (event) ->
  event.preventDefault()
  if $(event.target).find("textarea").val() != ""
    data = {}
    $(event.target).find("[name]").each ->
      data[$(this).attr("name")] = $(this).attr("value")
    $.post($(event.target).attr("action"), data)
    $(".post_response_form").html("Response submitted.  Refresh the page to see it.")

pm_event_handler = (plus_or_minus) ->
  (event) ->
    switch plus_or_minus
      when "plus"
        bottom_or_top = "top"
        opposite = "bottom"
        increment = 1
      when "minus"
        bottom_or_top = "bottom"
        opposite = "top"
        increment = -1
    event.stopPropagation()
    event.preventDefault()
    response_id = $(event.target).parents(".response").attr("id").split("_")[2]
    unless $("#forum_response_" + response_id).find(".udw-" + bottom_or_top).hasClass("active")
      $.post( "/comments/" + plus_or_minus + "1.json?comment_id=" + response_id, (data) ->
        middle = $("#forum_response_" + response_id).find(".udw-middle")
        increment *= 2 if $("#forum_response_" + response_id).find(".udw-" + opposite).hasClass("active")
        middle.text(parseInt(middle.text()) + increment)
        $("#forum_response_" + response_id).find(".udw-" + bottom_or_top).addClass("active")
        $("#forum_response_" + response_id).find(".udw-" + opposite).removeClass("active")
      )
