var fetchFormData = function(type, cb) {
  $.ajax({
    accepts: {json: 'application/json'},
    cache: false,
    dataType: 'json',
    error: function(xhr, textStatus, errorThrown) { console.log(errorThrown); },
    type: 'GET',
    url: '/' + type
  }).done(function(d) {
    for (var i in d) {
      $('form select.' + type).append('<option value="' + d[i].id + '">' + d[i].name + '</option');
    }
    if (typeof cb !== 'undefined') {
      cb(d);
    }
  });
}

var fetchPackages = function(event_id, cb) {
  $.ajax({
    accepts: {json: 'application/json'},
    cache: false,
    dataType: 'json',
    error: function(xhr, textStatus, errorThrown) { console.log(errorThrown); },
    type: 'GET',
    url: '/packages?event_id=' + event_id
  }).done(function(d) {
    cb(d);
  });
}

var fetchContacts = function(company_id, cb) {
  $.ajax({
    accepts: {json: 'application/json'},
    cache: false,
    dataType: 'json',
    error: function(xhr, textStatus, errorThrown) { console.log(errorThrown); },
    type: 'GET',
    url: '/contacts?company_id=' + company_id
  }).done(function(d) {
    cb(d);
  });
}

fetchFormData('events', function(data) {
  fetchPackages(data[0].id, function(packages) {
    for (var i in packages) {
      $('form select.packages').append('<option value="' + packages[i].id + '">' + packages[i].name + '</option');
    }
  })
});

$('form select.events').on('change', function() {
  var eventId = $(this).val();
  fetchPackages(eventId, function(packages) {
    $('form select.packages option').remove();
    for (var i in packages) {
      $('form select.packages').append('<option value="' + packages[i].id + '">' + packages[i].name + '</option');
    }
  })
});

fetchFormData('companies', function(data) {
  fetchContacts(data[0].id, function(contacts) {
    for (var i in contacts) {
      $('form select.contacts').append('<option value="' + contacts[i].id + '">' + contacts[i].first_name + ' ' + contacts[i].last_name + '</option');
    }
  })
});

$('form select.companies').on('change', function() {
  var companyId = $(this).val();
  fetchContacts(companyId, function(contacts) {
    $('form select.contacts option').remove();
    for (var i in contacts) {
      $('form select.contacts').append('<option value="' + contacts[i].id + '">' + contacts[i].first_name + ' ' + contacts[i].last_name + '</option');
    }
  })
});
