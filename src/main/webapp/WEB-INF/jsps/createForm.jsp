<%@ page session="false" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>

<html>
	<head>
		<title>Create Account</title>
		<link rel="stylesheet" href="<c:url value="/resources/blueprint/screen.css" />" >
		<link rel="stylesheet" href="<c:url value="/resources/popup.css" />" type="text/css">
		<script type="text/javascript" src="<c:url value="https://ajax.googleapis.com/ajax/libs/jquery/1.5.2/jquery.js" /> "></script>
	</head>
	<body>
		<div class="container">
			<h1>
				Create Vote
			</h1>
			<div class="span-12 last">	
				<form:form modelAttribute="vote" action="vote" method="post">
				  	<fieldset>		
						<legend>Vote Fields</legend>
						<p>
							<form:label	id="nameLabel" for="name" path="name" cssErrorClass="error">Vote Name</form:label><br/>
							<form:input path="name" /><form:errors path="name" />
						</p>
						<p>
							<form:label	id="descriptionLabel" for="description" path="description" cssErrorClass="error">Description</form:label><br/>
							<form:input path="description" /><form:errors path="description" />
						</p>
						<p>	
							<input id="create" type="submit" value="Create" />
						</p>
					</fieldset>
				</form:form>
			</div>
		</div>
		<div id="mask" style="display: none;"></div>
		<div id="popup" style="display: none;">
			<div class="span-8 last">
				<h3>Vote created successfully</h3>
				<form>
					<fieldset>
						<p>
							<label for="assignedId">Assigned Id</label><br/>
							<input id="assignedId" type="text" readonly="readonly" />		
						</p>
						<p>
							<label for="confirmedVoteName">Username</label><br/>
							<input id="confirmedVoteName" type="text" readonly="readonly" />
						</p>
						<p>	
							<label for="confirmedDescription">Description</label><br/>
							<input id="confirmedDescription" type="text" readonly="readonly" />
						</p>
					</fieldset>
				</form>
				<a href="#" onclick="closePopup();">Close</a>			
			</div>			
		</div>		
	</body>

	<script type="text/javascript">	
		$(document).ready(function() {
			// check name availability on focus lost
			$('#name').blur(function() {
				if ($('#name').val()) {	
					checkAvailability();
				}
			});
			$("#vote").submit(function() {
				var user = $(this).serializeObject();
				$.postJSON("vote", vote, function(data) {
					$("#assignedId").val(data.id);
					showPopup();
				});
				return false;				
			});
		});

		function checkAvailability() {
			$.getJSON("vote/availability", { name: $('#name').val() }, function(availability) {
				if (availability.available) {
					fieldValidated("name", { valid : true });
				} else {
					fieldValidated("name", { valid : false, message : $('#name').val() + " is not available "  });
				}
			});
		}

		function fieldValidated(field, result) {
			if (result.valid) {
				$("#" + field + "Label").removeClass("error");
				$("#" + field + "\\.errors").remove();
				$('#create').attr("disabled", false);
			} else {
				$("#" + field + "Label").addClass("error");
				if ($("#" + field + "\\.errors").length == 0) {
					$("#" + field).after("<span id='" + field + ".errors'>" + result.message + "</span>");		
				} else {
					$("#" + field + "\\.errors").html("<span id='" + field + ".errors'>" + result.message + "</span>");		
				}
				$('#create').attr("disabled", true);					
			}			
		}

		function showPopup() {
			$.getJSON("vote/" + $("#assignedId").val(), function(vote) {
				$("#confirmedVoteName").val(vote.name);
				$("#confirmedDescription").val(vote.description);
			});			
			$('body').css('overflow','hidden');
			$('#popup').fadeIn('fast');
			$('#mask').fadeIn('fast');
		}
		
		function closePopup() {
			$('#popup').fadeOut('fast');
			$('#mask').fadeOut('fast');
			$('body').css('overflow','auto');
			resetForm();
		}

		function resetForm() {
			$('#account')[0].reset();
		}
		
	</script>
	
</html>
