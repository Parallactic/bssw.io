var position = $(window).scrollTop();
var swap_menus_after = 139;
var halfstick = 2;
var sidestick = 60;

$(window).scroll(function() {
    var scroll = $(window).scrollTop();

    // deal w/main menu
    if (position > this.scrollY && !($('body').hasClass('scrollup'))
    && !($('.dropdown').hasClass('open')) ) {
      $('body').addClass('scrollup');
    }

    else if(scroll > position && ($('body').hasClass('scrollup')) ) {
      $('body').removeClass('scrollup');
    }

    position = scroll;
    if (position < 2) {
      $('body').removeClass('scrollup');
    }

    function checkMobileView(mediaQuery){
        if(mediaQuery.matches) {
            //reset dropdown from sticky nav, when scolling
            $("#main-nav[aria-expanded='true']").collapse('hide');
            $(".navbar-toggle").blur();
        }
    }

    checkMobileView(window.matchMedia("(min-width: 768px)"));
    
});


$('#scrollup-menu').click(function(){
    return(false);
});
