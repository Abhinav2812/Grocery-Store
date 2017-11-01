function checklogin()
{
    $.ajax({
        type: "POST",
        url: "data.php",
        data: {
            type: "checklogin"
        },        
        cache: false,               
        success: function(data) { 
            obj = JSON.parse(data);
            if('loc' in obj)
                window.location = obj['loc'];                   
        }
    });
}
