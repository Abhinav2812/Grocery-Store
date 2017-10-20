function sign_up(){
    var inputs = document.querySelectorAll('.input_form_sign');
    document.querySelectorAll('.ul_tabs > li')[1].className = "active"; 
    document.querySelectorAll('.ul_tabs > li')[0].className = ""; 
    setTimeout( function(){
        for(var d = 0; d < inputs.length ; d++  ) 
        {
            document.querySelectorAll('.input_form_sign')[d].className = "input_form_sign d_block active_inp";
        }
     },100);
    document.querySelector('.btn_sign').innerHTML = "SIGN UP";    
    document.getElementById('act').value="signup";
}



function sign_in(){
    var inputs = document.querySelectorAll('.input_form_sign');
    document.querySelectorAll('.ul_tabs > li')[0].className = "active"; 
    document.querySelectorAll('.ul_tabs > li')[1].className = ""; 
    setTimeout( function(){
        for(var d = 0; d < inputs.length ; d++  ) 
        {
            if(inputs[d].name === "uname" || inputs[d].name === "pass")
                document.querySelectorAll('.input_form_sign')[d].className = "input_form_sign d_block active_inp";    
            else
                document.querySelectorAll('.input_form_sign')[d].className = "input_form_sign d_block";
        }
     },100);
    document.querySelector('.btn_sign').innerHTML = "SIGN IN";
    document.getElementById('act').value="login";
}


window.onload =function(){
  document.querySelector('.cont_centrar').className = "cont_centrar cent_active";

}



