//botón de Inicio

$('#incio-page').find('.nav-link').addClass('active');

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

//botón de Repgrid

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
  
  