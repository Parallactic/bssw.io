$('document').ready(function(){


  $('li.dropdown.refine a').on('click', function (event) {
    $(this).parent().toggleClass('open');
    return false;
  });



  $('body').on('click', function (e) {
      if (!$('li.dropdown.refine').is(e.target)
          && $('li.dropdown.refine').has(e.target).length === 0
          && $('.open').has(e.target).length === 0
      ) {
          $('li.dropdown.refine').removeClass('open');
      }
  });



  $('input[type="checkbox"]').on('click', function() {
    $(this).parent('label').toggleClass('clicked');
  });



});
