$('#sidebarId').addClass('sidebar-light-primary');
$('#sidebarId').removeClass('sidebar-dark-primary');

$('#import-page, #excel-page, #form-page')
    .addClass('hidden');
/*
$('#incio-page').find('.nav-link').addClass('active');
*/

//funcionalidad de fullscreen

function openFullscreen(elem) {
  if (elem.requestFullscreen) {
    elem.requestFullscreen();
  } else if (elem.mozRequestFullScreen) { /* Firefox */
    elem.mozRequestFullScreen();
  } else if (elem.webkitRequestFullscreen) { /* Chrome, Safari and Opera */
    elem.webkitRequestFullscreen();
  } else if (elem.msRequestFullscreen) { /* IE/Edge */
    elem.msRequestFullscreen();
  }
};

$("#enter_fs" ).on( "click", function() {

  $('#exit_fs')
    .removeClass('hidden');

  $('#enter_fs')
    .addClass('hidden');
});

$( "#exit_fs").on( "click", function() {

  $('#enter_fs')
    .removeClass('hidden');

  $('#exit_fs')
    .addClass('hidden');
} );

/* botonera de navegación al cargar la página */
window.onload = (event) => {
  navButtons();
};

/* botonera de navegación al cambiar la página */
window.addEventListener('popstate', function () {
  navButtons();
});

function navButtons(){

  //botón de Inicio

  if (window.location.href.indexOf("/") > -1) {
    
    $('.nav-pills, #user-page')
        .find('.nav-link')
        .removeClass('active');

      $('#incio-page')
        .find('.nav-link')
        .addClass('active');
  };

  //botón de User

  if (window.location.href.indexOf("/user_home") > -1) {
   
     $('.nav-pills')
      .find('.nav-link')
      .removeClass('active');

    $('#user-page')
      .find('.nav-link')
      .addClass('active');
  };

  //botón de Patient

  if (window.location.href.indexOf("/patient") > -1) {
    
    $('.nav-pills, #user-page')
      .find('.nav-link')
      .removeClass('active');

      $('#patient-page')
        .find('.nav-link')
        .addClass('active');

     /* $('#import-page, #excel-page, #form-page')
        .removeClass('hidden');

  } else if (!window.location.href.indexOf("/import") > -1 || !window.location.href.indexOf("/excel") > -1 || !window.location.href.indexOf("/form") > -1){
    $('#import-page, #excel-page, #form-page')
      .addClass('hidden');
      */ 
  };

  //botón de Import
  if (window.location.href.indexOf("/import") > -1) {
    
     $('.nav-pills, #user-page')
      .find('.nav-link')
      .removeClass('active');

    $('#import-page')
      .find('.nav-link')
      .addClass('active');

      $('#import-page, #excel-page, #form-page')
        .removeClass('hidden');

  };

   //botón de Files
   if (window.location.href.indexOf("/excel") > -1) {
    
     $('.nav-pills, #user-page')
      .find('.nav-link')
      .removeClass('active');

    $('#excel-page')
      .find('.nav-link')
      .addClass('active')
      .addClass('sub');

      $('#import-page, #excel-page, #form-page')
        .removeClass('hidden');
  };

   //botón de Form
   if (window.location.href.indexOf("/form") > -1) {
    
     $('.nav-pills, #user-page')
      .find('.nav-link')
      .removeClass('active');

    $('#form-page')
      .find('.nav-link')
      .addClass('active')
      .addClass('sub');

      $('#import-page, #excel-page, #form-page')
        .removeClass('hidden');
  };

   //botón de RepGrid
   if (window.location.href.indexOf("/repgrid") > -1) {
    
     $('.nav-pills, #user-page')
      .find('.nav-link')
      .removeClass('active');

    $('#repgrid-page')
      .find('.nav-link')
      .addClass('active');
  };

   //botón de WimpGrid
   if (window.location.href.indexOf("/wimpgrid") > -1) {
    
     $('.nav-pills, #user-page')
      .find('.nav-link')
      .removeClass('active');

    $('#wimpgrid-page')
      .find('.nav-link')
      .addClass('active');
  };

  //botón de WimpGrid
  if (window.location.href.indexOf("/suggestion") > -1) {
    
    $('.nav-pills, #user-page')
     .find('.nav-link')
     .removeClass('active');

   $('#suggestion-page')
     .find('.nav-link')
     .addClass('active');
 };

}