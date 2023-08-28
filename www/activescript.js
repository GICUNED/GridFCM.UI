$('#sidebarId').addClass('sidebar-light-primary');
$('#sidebarId').removeClass('sidebar-dark-primary');
/*
$('#incio-page').find('.nav-link').addClass('active');
*/

window.onload = (event) => {
    //botón de Inicio
  
    if (window.location.href.indexOf("/") > -1) {
      
      $('.nav-pills')
          .find('.nav-link')
          .removeClass('active');
  
          $('.user-page')
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
      
      $('.nav-pills')
        .find('.nav-link')
        .removeClass('active');
  
        $('.user-page')
        .find('.nav-link')
        .removeClass('active');
  
      $('#patient-page')
        .find('.nav-link')
        .addClass('active');
    };
  
    //botón de Import
    if (window.location.href.indexOf("/import") > -1) {
      
      $('.nav-pills')
        .find('.nav-link')
        .removeClass('active');
  
        $('.user-page')
        .find('.nav-link')
        .removeClass('active');
  
      $('#import-page')
        .find('.nav-link')
        .addClass('active');
    };
  
     //botón de Files
     if (window.location.href.indexOf("/excel") > -1) {
      
      $('.nav-pills')
        .find('.nav-link')
        .removeClass('active');
  
        $('.user-page')
        .find('.nav-link')
        .removeClass('active');
  
      $('#excel-page')
        .find('.nav-link')
        .addClass('active')
        .addClass('sub');
    };
  
     //botón de Form
     if (window.location.href.indexOf("/form") > -1) {
      
      $('.nav-pills')
        .find('.nav-link')
        .removeClass('active');
  
        $('.user-page')
        .find('.nav-link')
        .removeClass('active');
  
      $('#form-page')
        .find('.nav-link')
        .addClass('active')
        .addClass('sub');
    };
  
     //botón de RepGrid
     if (window.location.href.indexOf("/repgrid") > -1) {
      
      $('.nav-pills')
        .find('.nav-link')
        .removeClass('active');
  
        $('.user-page')
        .find('.nav-link')
        .removeClass('active');
  
      $('#repgrid-page')
        .find('.nav-link')
        .addClass('active');
    };
  
     //botón de WimpGrid
     if (window.location.href.indexOf("/wimpgrid") > -1) {
      
      $('.nav-pills')
        .find('.nav-link')
        .removeClass('active');
  
        $('.user-page')
        .find('.nav-link')
        .removeClass('active');
  
      $('#wimpgrid-page')
        .find('.nav-link')
        .addClass('active');
    };
      
  
};

window.addEventListener('popstate', function () {

  //botón de Inicio

  if (window.location.href.indexOf("/") > -1) {
    
    $('.nav-pills')
        .find('.nav-link')
        .removeClass('active');

        $('.user-page')
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
    
    $('.nav-pills')
      .find('.nav-link')
      .removeClass('active');

      $('.user-page')
      .find('.nav-link')
      .removeClass('active');

    $('#patient-page')
      .find('.nav-link')
      .addClass('active');
  };

  //botón de Import
  if (window.location.href.indexOf("/import") > -1) {
    
    $('.nav-pills')
      .find('.nav-link')
      .removeClass('active');

      $('.user-page')
      .find('.nav-link')
      .removeClass('active');

    $('#import-page')
      .find('.nav-link')
      .addClass('active');
  };

   //botón de Files
   if (window.location.href.indexOf("/excel") > -1) {
    
    $('.nav-pills')
      .find('.nav-link')
      .removeClass('active');

      $('.user-page')
      .find('.nav-link')
      .removeClass('active');

    $('#excel-page')
      .find('.nav-link')
      .addClass('active')
      .addClass('sub');
  };

   //botón de Form
   if (window.location.href.indexOf("/form") > -1) {
    
    $('.nav-pills')
      .find('.nav-link')
      .removeClass('active');

      $('.user-page')
      .find('.nav-link')
      .removeClass('active');

    $('#form-page')
      .find('.nav-link')
      .addClass('active')
      .addClass('sub');
  };

   //botón de RepGrid
   if (window.location.href.indexOf("/repgrid") > -1) {
    
    $('.nav-pills')
      .find('.nav-link')
      .removeClass('active');

      $('.user-page')
      .find('.nav-link')
      .removeClass('active');

    $('#repgrid-page')
      .find('.nav-link')
      .addClass('active');
  };

   //botón de WimpGrid
   if (window.location.href.indexOf("/wimpgrid") > -1) {
    
    $('.nav-pills')
      .find('.nav-link')
      .removeClass('active');

      $('.user-page')
      .find('.nav-link')
      .removeClass('active');

    $('#wimpgrid-page')
      .find('.nav-link')
      .addClass('active');
  };
    
});

/*

//botón de Inicio

$('#incio-page').on('click', function () {
  $('.nav-pills')
  .find('.nav-link')
  .removeClass('active');

  $('.user-page')
  .find('.nav-link')
  .removeClass('active');

$(this)
  .find('.nav-link')
  .addClass('active');

  });

//botón de User

$('#user-page').on('click', function () {

$('.nav-pills')
  .find('.nav-link')
  .removeClass('active');

$('#user-page')
  .find('.nav-link')
  .addClass('active');

  });

//botón de Patient

$('#patient-page').on('click', function () {
  
  $('.nav-pills')
  .find('.nav-link')
  .removeClass('active');

  $('.user-page')
  .find('.nav-link')
  .removeClass('active');

  $(this)
  .find('.nav-link')
  .addClass('active');
    
});
  
//botón de Import
  
$('#import-page').on('click', function () {

  $('.nav-pills')
    .find('.nav-link')
    .removeClass('active');

  $('.user-page')
    .find('.nav-link')
    .removeClass('active');

  $(this)
    .find('.nav-link')
    .addClass('active');

  });

//botón de Files

$('#excel-page').on('click', function () {

    $('.nav-pills')
        .find('.nav-link')
        .removeClass('active');

    $('.user-page')
        .find('.nav-link')
        .removeClass('active');

    $(this)
        .find('.nav-link')
       .addClass('active')
       .addClass('sub');
})

//botón de Form

$('#form-page').on('click', function () {

  $('.nav-pills')
      .find('.nav-link')
      .removeClass('active');

  $('.user-page')
      .find('.nav-link')
      .removeClass('active');


  $(this)
      .find('.nav-link')
     .addClass('active')
     .addClass('sub');
})
  
//botón de Repgrid

$('#repgrid-page').on('click', function () {

    $('.nav-pills')
        .find('.nav-link')
        .removeClass('active');

    $('.user-page')
        .find('.nav-link')
        .removeClass('active');


    $(this)
        .find('.nav-link')
       .addClass('active');
})

//botón de WimpGrid

$('#wimpgrid-page').on('click', function () {

  $('.nav-pills')
      .find('.nav-link')
      .removeClass('active');

  $('.user-page')
      .find('.nav-link')
      .removeClass('active');


  $(this)
      .find('.nav-link')
     .addClass('active');
})
  
  */