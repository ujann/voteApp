/**
 * 
 */
package techadventure.voteApp.web.controller;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletResponse;
import javax.validation.ConstraintViolation;
import javax.validation.Validator;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import techadventure.voteApp.web.entity.AvailabilityStatus;
import techadventure.voteApp.web.entity.Vote;
import techadventure.voteApp.web.exception.ResourceNotFoundException;

/**
 * @author uj
 *
 */
@Controller
@RequestMapping(value="/vote")
public class VoteController {
	private Map<String, Vote> votes;
	private Validator validator;
	
	private static int LASTVOTEID = 0;
	
	@Autowired
	public VoteController(Validator validator) {
		this.validator = validator;
		votes = new HashMap<String, Vote>();
		Vote vote = new Vote();
		vote.setId("" + ++LASTVOTEID);
		vote.setName("testName");
		vote.setDescription("test description");
		votes.put(vote.getId(), vote);
	}
	
	@RequestMapping(method=RequestMethod.GET)
	public String renderCreateForm(Model model) {
		model.addAttribute(new Vote());
		return "createForm";
	}

	@RequestMapping(value="/availability", method=RequestMethod.GET)
	public @ResponseBody AvailabilityStatus getAvailability(@RequestParam String voteName) {
		for( Vote vote : this.votes.values() ){
			if( vote.getName().equals(voteName)){
				return AvailabilityStatus.notAvailable(voteName);
			}
		}
		return AvailabilityStatus.available();
	}
	
	@RequestMapping(method=RequestMethod.POST)
	public @ResponseBody Map<String, ? extends Object> create(@RequestBody Vote vote, HttpServletResponse response) {
		Set<ConstraintViolation<Vote>> failures = validator.validate(vote);
		if (!failures.isEmpty()) {
			response.setStatus(HttpStatus.BAD_REQUEST.value());
			return validationMessages(failures);
		} else {
			votes.put("" + ++LASTVOTEID, vote);
			return Collections.singletonMap("id", ""  +vote.getId());
		}
	}
	
	@RequestMapping(value="{id}", method=RequestMethod.GET)
	public @ResponseBody Vote get(@PathVariable String id) {
		Vote account = votes.get(id);
		if (account == null) {
			throw new ResourceNotFoundException(id);
		}
		return account;
	}
	
	// internal helpers
	
	private Map<String, String> validationMessages(Set<ConstraintViolation<Vote>> failures) {
		Map<String, String> failureMessages = new HashMap<String, String>();
		for (ConstraintViolation<Vote> failure : failures) {
			failureMessages.put(failure.getPropertyPath().toString(), failure.getMessage());
		}
		return failureMessages;
	}
}
