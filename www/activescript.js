$('#sidebarId').addClass('sidebar-light-primary');
$('#sidebarId').removeClass('sidebar-dark-primary');

$('#import-page, #excel-page, #form-page')
    .addClass('hidden');
  
//Activar tooltips bootstrap-4

//$(function () {
  //  $('[data-toggle="tooltip"]').tooltip()
//})


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

  // Función para alternar la simulación de pantalla completa
  function toggleFullscreenSimulation(elemId) {
    const elem = $(elemId);
    
    elem.toggleClass('fullscreen-style');
    // Encuentra todos los botones "enter_fs" y "exit_fs"
    const enterFsButtonsMb = $("button[id^='mb_enter_fs_']");
    const exitFsButtonsMb = $("button[id^='mb_exit_fs_']");
    
    // Verifica si el elemento tiene la clase 'fullscreen-style'
    if (elem.hasClass('fullscreen-style')) {
      // Simula entrar en pantalla completa
      exitFsButtonsMb.removeClass("hidden");
      enterFsButtonsMb.addClass("hidden");
    } else {
      // Simula salir de pantalla completa
      exitFsButtonsMb.addClass("hidden");
      enterFsButtonsMb.removeClass("hidden");
    }

    
  }

$(document).ready(function() {
  // Encuentra todos los botones "enter_fs" y "exit_fs"
  const enterFsButtons = $("button[id^='enter_fs_']");
  const exitFsButtons = $("button[id^='exit_fs_']");

  // Agrega un evento fullscreenchange al documento
  document.addEventListener("fullscreenchange", function() {
    // Encuentra el elemento en modo de pantalla completa
    const fullscreenElement = document.fullscreenElement || document.mozFullScreenElement || document.msFullscreenElement || document.webkitFullscreenElement;

    if (fullscreenElement) {
      exitFsButtons.removeClass("hidden");
      enterFsButtons.addClass("hidden");

    } else {
      exitFsButtons.addClass("hidden");
      enterFsButtons.removeClass("hidden");
    }
  });
});

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
    
    $('.nav-pills, #profile')
        .find('.nav-link')
        .removeClass('active');

      $('#incio-page')
        .find('.nav-link')
        .addClass('active');

      $('.footer-psychlabuned')
        .addClass('hidden');
  }
  
  //botón de User

  if (window.location.href.indexOf("/user_home") > -1) {
   
     $('.nav-pills')
      .find('.nav-link')
      .removeClass('active');

    $('#profile')
      .find('.nav-link')
      .addClass('active');

      $('.footer-psychlabuned')
      .removeClass('hidden');
  };

  //botón de Patient

  if (window.location.href.indexOf("/patient") > -1) {
    
    $('.nav-pills, #profile')
      .find('.nav-link')
      .removeClass('active');

      $('#patient-page')
        .find('.nav-link')
        .addClass('active');

        $('.footer-psychlabuned')
      .removeClass('hidden');

     /* $('#import-page, #excel-page, #form-page')
        .removeClass('hidden');

  } else if (!window.location.href.indexOf("/import") > -1 || !window.location.href.indexOf("/excel") > -1 || !window.location.href.indexOf("/form") > -1){
    $('#import-page, #excel-page, #form-page')
      .addClass('hidden');
      */ 
  };

  //botón de Import
  if (window.location.href.indexOf("/import") > -1) {
    
     $('.nav-pills, #profile')
      .find('.nav-link')
      .removeClass('active');

    $('#import-page')
      .find('.nav-link')
      .addClass('active');

      $('#import-page, #excel-page, #form-page')
        .removeClass('hidden');

        $('.footer-psychlabuned')
      .removeClass('hidden');

  };

   //botón de Files
   if (window.location.href.indexOf("/excel") > -1) {
    
     $('.nav-pills, #profile')
      .find('.nav-link')
      .removeClass('active');

    $('#excel-page')
      .find('.nav-link')
      .addClass('active')
      .addClass('sub');

      $('.footer-psychlabuned')
      .removeClass('hidden');

      $('#import-page, #excel-page, #form-page')
        .removeClass('hidden');
  };

   //botón de Form
   if (window.location.href.indexOf("/form") > -1) {
    
     $('.nav-pills, #profile')
      .find('.nav-link')
      .removeClass('active');

    $('#form-page')
      .find('.nav-link')
      .addClass('active')
      .addClass('sub');

      $('.footer-psychlabuned')
      .removeClass('hidden');

      $('#import-page, #excel-page, #form-page')
        .removeClass('hidden');
  };

   //botón de RepGrid
   if (window.location.href.indexOf("/repgrid") > -1) {
    
     $('.nav-pills, #profile')
      .find('.nav-link')
      .removeClass('active');

    $('#repgrid-page')
      .find('.nav-link')
      .addClass('active');

      $('.footer-psychlabuned')
      .removeClass('hidden');
  };

   //botón de WimpGrid
   if (window.location.href.indexOf("/wimpgrid") > -1) {
    
     $('.nav-pills, #profile')
      .find('.nav-link')
      .removeClass('active');

    $('#wimpgrid-page')
      .find('.nav-link')
      .addClass('active');

      $('.footer-psychlabuned')
      .removeClass('hidden');
  };

  //botón de WimpGrid
  if (window.location.href.indexOf("/suggestion") > -1) {
    
    $('.nav-pills, #profile')
     .find('.nav-link')
     .removeClass('active');

   $('#suggestion-page')
     .find('.nav-link')
     .addClass('active');

     $('.footer-psychlabuned')
      .removeClass('hidden');
 };

 if (window.location.href.indexOf("/plan") > -1) {
    
  $('.nav-pills, #profile')
   .find('.nav-link')
   .removeClass('active');

 $('#plan-page')
   .find('.nav-link')
   .addClass('active');

   $('.footer-psychlabuned')
      .removeClass('hidden');
};

if (window.location.href.indexOf("/user") > -1) {
    
  $('.nav-pills')
   .find('.nav-link')
   .removeClass('active');

 $('#profile')
   .find('.nav-link')
   .addClass('active');

   $('.footer-psychlabuned')
    .removeClass('hidden');
}

}