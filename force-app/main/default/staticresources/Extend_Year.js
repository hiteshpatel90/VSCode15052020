$(document).ready(function() {
	var startYear=1982;
	var endYear=2034;
	var optionsString='';
	if(startYear<endYear){
		for(i=startYear;i<endYear+1;i++){
			optionsString += "<option value=\""+i+"\">"+i+"</option>";
		}
		$('#calYearPicker').html(optionsString);
	}
	$('#sidebarDiv #hideMyParent').parent().parent().hide();
});