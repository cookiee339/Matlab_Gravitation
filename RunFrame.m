function [timeTaken, remainingBodies] = RunFrame(gravitationalBodies, deltaTime, seconds)
	tic
	
	remainingBodies = gravitationalBodies;
	
	% usuwa nie istniej¹ce cia³a z ostatniej klatki
    
	deadIndices = [];
	for i = 1 : size(remainingBodies, 2)
		gravitationalBody = remainingBodies(i);
		if (~gravitationalBody.IsAlive)
			deadIndices = [deadIndices, i];
		end
	end
	
	if (size(deadIndices) > 0)
		% usuwa planety z tablicy
		remainingBodies(deadIndices) = [];
	end
	
	%dla wszystkich cia³
	for i = 1 : size(remainingBodies, 2)
		gravitationalBody = remainingBodies(i);
		
		if (~gravitationalBody.IsAlive)
			continue;
		end

		% sprawdza kolizje
		for j = 1 : size(remainingBodies, 2)
			otherGravitationalBody = remainingBodies(j);

			% pomijanie tych samych cia³
			if (j == i)
				continue;
			end

			if (~otherGravitationalBody.IsAlive)
				continue;
			end
			
			isColliding = gravitationalBody.IsCollidingWith(otherGravitationalBody);
			if (isColliding)
				if (otherGravitationalBody.IsFixedPoint)
					otherGravitationalBody.AbsorbBody(gravitationalBody);
				else
					if (gravitationalBody.CalculateMass() > otherGravitationalBody.CalculateMass())
						gravitationalBody.AbsorbBody(otherGravitationalBody);
					else
						otherGravitationalBody.AbsorbBody(gravitationalBody);
					end
					
				end
			else
				% oblicza si³y
				gravitationalBody.ComputeForces(otherGravitationalBody);
			end
		end
	end

	% symulacja wszystkich si³
	for j = 1 : size(remainingBodies, 2)
		gravitationalBody = remainingBodies(j);

		if (~gravitationalBody.IsAlive)
			continue;
		end	
		
		gravitationalBody.SimulateForces(deltaTime, seconds);
	end
	
	% rysowanie
	%hold(graphAxes, 'off') % czyœci poprzednie 
    
    hold off
	for i = 1 : size(remainingBodies, 2)
		gravitationalBody = remainingBodies(i);
		
		if (~gravitationalBody.IsAlive)
			continue;
		end

		gravitationalBody.Draw();
		
		if (i == 1)
			
            hold on
		end
	end
	
	
	drawnow;
	pause(0.01);
	%remainingBodies = gravitationalBodies;
	timeTaken = toc;
end