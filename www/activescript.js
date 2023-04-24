$('#incio-page').find('.nav-link').addClass('active');
$('#incio-page').on('click', function () {
      $(this)
          .find('.nav-link')
         .addClass('active');
  
      $('#user-page')
        .find('.nav-link')
        .removeClass('active');
  
      $('#import-page')
        .find('.nav-link')
        .removeClass('active');
  
      $('#excel-page')
        .find('.nav-link')
        .removeClass('active');
  });
  
  $('#user-page').on('click', function () {
      $(this)
          .find('.nav-link')
         .addClass('active');
  
      $('#incio-page')
        .find('.nav-link')
        .removeClass('active');
  
      $('#import-page')
        .find('.nav-link')
        .removeClass('active');
  
      $('#excel-page')
        .find('.nav-link')
        .removeClass('active');
  });
  
  $('#import-page').on('click', function () {
      $(this)
          .find('.nav-link')
         .addClass('active');
  
      $('#user-page')
        .find('.nav-link')
        .removeClass('active');
  
      $('#incio-page')
        .find('.nav-link')
        .removeClass('active');
  
      $('#excel-page')
        .find('.nav-link')
        .removeClass('active');
  });
  
  $('#excel-page').on('click', function () {
      $(this)
          .find('.nav-link')
         .addClass('active');
  
      $('#user-page')
        .find('.nav-link')
        .removeClass('active');
  
      $('#import-page')
        .find('.nav-link')
        .removeClass('active');
  
      $('#incio-page')
        .find('.nav-link')
        .removeClass('active');
  })