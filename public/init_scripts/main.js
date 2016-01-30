$(document).ready(function() {
    $.post('/init_db', {username:'ryan', password:'password'}, function(data, textStatus, xhr) {
        console.log(data);
    });
});
