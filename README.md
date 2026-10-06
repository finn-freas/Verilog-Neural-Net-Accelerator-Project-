I've been trying to learn Verilog, and this project is essentially a way of learning while also getting to use it! 

I have built:

- A multiply-accumulate unit, which multiplies each input by its weight, once per clock cycle, and adds the result to a running total that starts at the neuron's bias. After all inputs are added, the total is that neuron's output.

- A control state module, which uses its current state plus neuron and input counters to feed the MAC the right weight and input each cycle and save each neuron's result. 



Currently working on training a model so I can use its weights for testing.
