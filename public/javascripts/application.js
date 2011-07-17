// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(document).ready(function(){

//      $("table").delegate("a", "click", function(){
  $("a.ajax_lock").live("click", function(){ // people say that "live" fails on some browsers
    clicked_link_id = $(this).attr('id');
    $.post('/translation_file/ajax_lock_pofile/' + clicked_link_id.substr(1), function(data){
      $("tr.ajax_lock_div#" + clicked_link_id).html(data);
    }, {}, {}, 'html');
  });

});
