// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require bootstrap-sprockets
//= require lightbox-bootstrap
//= require algolia/v3/algoliasearch.min
//= require_tree .

    
$(document).ready(function(){

    
    // var client = algoliasearch(ApplicationID, Search-Only-API-Key);
    // var index = client.initIndex('YourIndexName');
    // index.search('something', { hitsPerPage: 10, page: 0 })
    // 	.then(function searchDone(content) {
    // 	    console.log(content)
    // 	})
    // 	.catch(function searchFailure(err) {
    // 	    console.error(err);
    // 	});

    $(".page:not('.lightbox')").wrap("<div class='img-wrapper'></div>");

    //alert(getCookie('hideAnnouncement'));
    function deleteCookie(name) { setCookie(name, '', -1); }

    function setCookie(name, value, days) {
        var d = new Date;
        d.setTime(d.getTime() + 24*60*60*1000*days);
        document.cookie = name + "=" + value + ";path=/;expires=" + d.toGMTString();
    }

    function getCookie(name) {
        var v = document.cookie.match('(^|;) ?' + name + '=([^;]*)(;|$)');
        return v ? v[2] : null;
    }


    $('#close').click(function(){
        $("#close").parent().parent().parent().parent().hide();
        $.ajax({ url: '/announcements/close', method: 'post'});
        setCookie('hideAnnouncement', true, 1);
    });

    //deleteCookie('hideAnnouncement');

    if (getCookie('hideAnnouncement') === 'true') {
        $('.announcement').css('display', 'none');
    } else {
        $('.announcement').css('display', 'block');
    }

    
    
    $('.permalink').click(function(e) {
        e.preventDefault();
        // $('.socials').find('a').hide();
        $('.short_lived').css('display', 'inline'); 
        $('.short_lived').show();
        var copyText = $(this).attr('href');
        var textArea = document.createElement("textarea");
        $('body').prepend(textArea);
        textArea.value = copyText;
        textArea.focus();
        textArea.select();
        success = new Promise(function(resolve, reject) {
            resolve(document.execCommand('copy'));
        });
        success.then(function(value) {

            $('.short_lived').fadeOut(750); 
            // setTimeout(function(){ 
            //     $('.socials').find('a').fadeIn(1250);
            // }, 500);
        });
        document.body.removeChild(textArea);
    });

    // open the sidebar menu for the topic we're viewing
    // search = window.location.search.substr(1)
    search = window.location.search
    page = window.location.pathname
    whichPage = page+search
    // if (page == '/events' && search == '') {
    //     $('.to-top').hide();
    // }
    link = $('a[href=\''+whichPage+'\']');
    ancestor = link.parent().parent().parent().parent()
    if (search && link) {
        $('a[href=\''+whichPage+'\']').parent().addClass('active').parent().parent().parent().addClass('show');
        $('a[href=\''+whichPage+'\']').parent().addClass('active').parent().parent().parent().siblings().children().children().removeClass('collapsed');
        //$('a[href=\''+whichPage+'\']').parent().addClass('active').parent().parent().parent().collapsed();
        //$('a[href=\''+whichPage+'\']').parent().addClass('active').parent().parent().parent().addClass('TEST');

        //$('a[href=\''+whichPage+'\']').parent().parent().parent().parent().addClass('TEST');
    }


});


