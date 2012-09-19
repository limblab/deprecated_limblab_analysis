

class Staircase {
public:
	Staircase();
	double getValue();
	int getIteration();
	void restart();

	void stepForward();
	void stepBackward();

	void setStep(double step);
	void setStartValue(double startValue);
	void setRatio(int ratio);

	void setForwardLimit(double limit);
	void setUseForwardLimit(bool b);
	void setBackwardLimit(double limit);
	void setUseBackwardLimit(bool b);
	void setUseSoftLimit(bool b);

protected:
	double step_size;
	double current_value;
	int step_ratio;

	double forward_limit;
	double backward_limit;
	bool use_forward_limit;
	bool use_backward_limit;
	bool soft_limit; // if true then don't go all the way to the limit if you would step over.

	int iteration;

	// These params describe the requested behavior but will not
	// take effect until restart is called.
	double param_step;
	double param_start_value;
	double param_forward_limit;
	double param_backward_limit;
	bool param_use_forward_limit;
	bool param_use_backward_limit;
	int param_ratio;

};

Staircase::Staircase() { }

double Staircase::getValue() {
	return current_value;
}

void Staircase::restart() {
	step_size = param_step;
	current_value = param_start_value;
	step_ratio = param_ratio;

	forward_limit = param_forward_limit;
	backward_limit = param_backward_limit;
	use_forward_limit = param_use_forward_limit;
	use_backward_limit = param_use_backward_limit;

	iteration = 0;
}

void Staircase::setStep(double step) {
	param_step = step;
}

void Staircase::setStartValue(double startValue) {
	param_start_value = startValue;
}

void Staircase::setUseSoftLimit(bool b) {
	soft_limit = b;
}

void Staircase::setRatio(int ratio) {
	param_ratio = ratio;
}

int Staircase::getIteration() {
	return iteration;
}

void Staircase::stepForward() {
	iteration++;

	current_value += step_size;

	if (use_forward_limit && ((step_size<0)!=(current_value>forward_limit))) {
		current_value = (soft_limit ? current_value - step_size : forward_limit);
	}
}

/*
            current ?= forward limit:
			 >       <  
          +------+------+
Step: Pos | set  | ign  |
      Neg | ign  | set  |

  step < 0 != current > fl 

*/
void Staircase::stepBackward() {
	iteration++;
	current_value -= step_size * step_ratio;

	if (use_forward_limit && ((step_size<0)!=(current_value<backward_limit))) {
		current_value = (soft_limit ? current_value + step_size*step_ratio : backward_limit);
	}
}

// Limits
void Staircase::setForwardLimit(double limit) {param_forward_limit = limit;}
void Staircase::setUseForwardLimit(bool b) {param_use_forward_limit = b;}
void Staircase::setBackwardLimit(double limit) {param_backward_limit = limit;}
void Staircase::setUseBackwardLimit(bool b) {param_use_backward_limit = b;}
