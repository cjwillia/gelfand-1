// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery_nested_form
//= require foundation
//= require foundation.equalizer.js
//= require foundation-datepicker.js
//= require chosen.jquery.min.js
//= require jquery.tagsinput.min.js
//= require_tree .

// MENTION this: if user doesnt include the @ in the email, then a cool notification pops up
$(document).ready(function(){



  /* BG_Check Index custom jquery dropdown */

  function toggleOpen(id) {
    //If there are any open dropdowns, close them
    if( $(".open").length > 0) {
      toggleClosed($(".open")[0].id.replace(/[\D]+/, ""));
    }

    //Get the corresponding divs
    var toggler = $('#toggler' + id);
    var hiddenPanel = $('#hiddenpanel' + id);

    hiddenPanel.slideDown();

    //add a class to the toggler container and style changes can be put in the css
    toggler.addClass('open');

    //unbind the last action and bind the close action
    toggler.unbind();
    toggler.click(function() {
      toggleClosed(id);
    });
  }

  function toggleClosed(id) {
    //Get corresponding divs
    var toggler = $('#toggler' + id);
    var hiddenPanel = $('#hiddenpanel' + id);

    hiddenPanel.slideUp();

    //remove open class for css style changes
    toggler.removeClass('open');

    //unbind the last action and bind the open action
    toggler.unbind();
    toggler.click(function() {
      toggleOpen(id);
    });
  }

  $('.issues-toggler').click(function() {
    //Get the id number of the toggler
    var id = this.id.replace(/[\D]+/, "");
    toggleOpen(id);
  });


  /* search functionality */
  $("bg_checks_search").submit(function() {
      $.get(this.action, $(this).serialize(), null, "script");
      return false; // so doesnt submit actual form
  }); 

  //datepicker code
  $('.datepicker').fdatepicker({
    format: 'yyyy-mm-dd'
  });

  $(window).bind("load", function () {
    var footer = $("#footer");
    var pos = footer.position();
    var height = $(window).height();
    height = height - pos.top;
    height = height - footer.height();
    if (height > 0) {
        footer.css({
            'margin-top': height + 'px'
        });
    }
  });

  //code to fade out alert boxes
  $('.alert-box').fadeIn('normal', function() {
      $(this).delay(2000).fadeOut();
   });


  //chosen (autocomplete) code
  $('.chosen-select').chosen({

  });

$('#tags').tagsInput({'defaultText':'Add email'});

});

$(function(){ $(document).foundation(); });



