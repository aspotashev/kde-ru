// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function ajax_lock_pofile(id)
{
  $.post('/translation_file/ajax_lock_pofile/' + id,
         function(data) { $("tr.ajax_lock_div#a" + id).html(data); },
         {}, {}, 'html');
}

$(document).ready(function(){
    // .....
});
