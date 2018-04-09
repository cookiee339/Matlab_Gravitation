classdef GravitationalBody < handle
	%  GravitationalBody Struktura reprezentuj¹ca cia³o grawitacyjne.
	%   Ta klasa zawiera wszystkie dane i metody wymagane do przechowywania i obliczania symulacji.
	
	properties	
		IsAlive = true;
		
		% Pozycja
		XY = [0, 0]
		
		% Mass
		Radius = 1
		
		% kolor planety
		RGB = [1, 1, 1]
		
		% sily
	
        VelocityVector = [0, 0]
		AccelerationVector = [0, 0]
		
		% Obiekt graficzny na osiach symulacji
		GraphicalObject
		% Niezale¿nie od tego, czy to cia³o jest sta³ym punktem symulacji
		IsFixedPoint
	end
	
	methods (Static)
		function body = CreateRandomBody(minMaxX, minMaxY, minMaxR)
			% CREATERANDOMBODY tworzy ciala i ich parametry
			
			
			% obsluga bledow
			if (numel(minMaxX) ~= 2)
				fprintf('"minXY" musi byæ  2-elementowym wektorem');
			end
			
			if (numel(minMaxY) ~= 2)
				fprintf('"maxXY" musi byæ  2-elementowym wektorem');
			end
			
			if (numel(minMaxR) ~= 2)
				fprintf('"minMaxR" musi byæ  2-elementowym wektorem');
			end
			
					
			% losowanie polozenia
			randX = minMaxX(1) + (minMaxX(2) - minMaxX(1)).*rand(1,1);
			randY = minMaxY(1) + (minMaxY(2) - minMaxY(1)).*rand(1,1);
						
			% losuje promien
			randR = (minMaxR(2) - minMaxR(1)).*rand(1,1) + minMaxR(1);
						
			% losuje kolor ciala
			randColour = rand(1, 3);
			VelocityVector=[200*rand()-100,200*rand()-100];
			% inicjalizacja nowego ciala
			body = GravitationalBody([randX, randY], randR, randColour, false);
        end
        
        %zwraca wartoc predkosci
        function result = lerp(v0, v1, t)
            result = (1-t)*v0+t*v1;  
		end
		%function Simulate()
		%%function SimulateSimple(bodyCount)
		
		function SimulateParameterized(bodyCount, minMaxX, minMaxY, minMaxR, withGreatAttractor, timeStep)
			% Setup - time delta
			lastFrameTime = 5;

			% Setup - rendering
			clf('reset');
			graphAxes = axes('PlotBoxAspectRatio', [1, 1, 1]);
			axis(graphAxes, [minMaxX, minMaxY]);
			grid(graphAxes, 'on');

			% tworzenie obiektoww
			if (withGreatAttractor)
				gravitationalBodies = GravitationalBody.empty(bodyCount + 1, 0);
				for i = 1 : bodyCount
					gravitationalBodies(i) = GravitationalBody.CreateRandomBody(minMaxX, minMaxY, minMaxR);
				end

				gravitationalBodies(bodyCount + 1) = GravitationalBody([minMaxX(2) / 2, minMaxY(2) / 2], minMaxR(2) * 2, [1, 1, 0], true);
			else
				gravitationalBodies = GravitationalBody.empty(bodyCount, 0);
				for i = 1 : bodyCount
					gravitationalBodies(i) = GravitationalBody.CreateRandomBody(minMaxX, minMaxY, minMaxR);
				end
            end
            

			% symulacja

			while (size(gravitationalBodies,  2) > 1)
                %zmiana ostatniej klattki
				[lastFrameTime, gravitationalBodies] = GravitationalBody.RunFrame(gravitationalBodies, lastFrameTime, timeStep, graphAxes);
				lastFrameTime = lastFrameTime * 1000;
			end
        end
    end
        
       
	
	methods
		function obj = GravitationalBody(initialXY, initialRadius, initialRGB, isFixedPoint)
			% GRAVITATIONALBODY tworzymy nowa instancje
			% GravitationalBody class.
			%	GRAVITATIONALBODY(this, initialXY, initialRadius, initialRGB, isFixedPoint)
		
			
			obj.XY = initialXY;
			obj.Radius = initialRadius;
			obj.RGB = initialRGB;
			obj.IsFixedPoint = isFixedPoint;
		end
		
		function isColliding = IsCollidingWith(this, gravitationalBody)
			%   SCOLLIDINGWITH Okreœla, czy to cia³o nie koliduje z podanym.
			%	zwraca true lub false
			
			if (~isa(gravitationalBody, 'GravitationalBody'))
				fprintf('Invalid input object to ApplyForces - must be another gravitational body.');
				return;
			end
			
			collisionThreshold = this.Radius + gravitationalBody.Radius;
			
			if (this.DistanceTo(gravitationalBody) <= collisionThreshold)
				isColliding = true;
			else
				isColliding = false;
			end
		end
		
		function distance = DistanceTo(this, gravitationalBody)
			% DISTANCE oblicza odleglosc miedzy cialami
            
            
			if (~isa(gravitationalBody, 'GravitationalBody')) %kontrola bledów
				fprintf('BLAD WEJSCIA .'); 
				return;
			end
			
			distance = sqrt ( ...
				(gravitationalBody.XY(1) - this.XY(1))^2 ...
				+ ...
				(gravitationalBody.XY(2) - this.XY(2))^2 ...
				);
		end
		
		function mass = CalculateMass(this)
			% COMPUTEMASS oblicza mase cia³a ( gestosc jest wartoscia
			% przyblizona dla ziemi
            
			
			mass = this.Radius^(2) * pi * 5.5;
		end
		
		
		function ComputeForces(this, gravitationalBody)
			%   COMPUTEFORCES Oblicza si³y miêdzy cia³em wejœciowym a tym cia³e
            %  planety nie obliczaj¹ si³y na sobie
            
            
			if (this.IsFixedPoint)% kontrola b³êdów
				return;
			end
			
			if (~isa(gravitationalBody, 'GravitationalBody'))
				fprintf('B³ad - musi byæ inny obiekt'); % kontrola b³êdów
				return;
			end
			
			% Oblicz si³ê, jak¹ cia³o wejœciowe wywiera na to cia³o i 
			% stosuje to wyliczenie dla zmiennych:
            % this.Acceleration -przyspiesszenie
			% this.XYDirection kierunek
            
            G = 6.67408e-11;
            
			distance = this.DistanceTo(gravitationalBody);
            force = G * ((this.CalculateMass() * gravitationalBody.CalculateMass()) / distance^2);
			forceVector = force * (this.XY - gravitationalBody.XY) / distance; 
			
			this.AccelerationVector = this.AccelerationVector - (forceVector / this.CalculateMass());
		end
		
		
		function SimulateForces(this, deltaTime, timeStep)
			% SIMULATEFORCES -Symuluje obliczone si³y przez pewien okres czasu
            % Zastosuj obliczone si³y do danego cia³a 
			
			this.VelocityVector = this.VelocityVector + ((deltaTime * timeStep) * this.AccelerationVector);
			this.XY = this.XY + ((deltaTime * timeStep) * this.VelocityVector);
        end
        
		function AbsorbBody(this, gravitationalBody)
			% powstajace ciala.
			
		
			this.Radius = sqrt((gravitationalBody.Radius^2*pi + this.Radius^2*pi) / pi);
			
		
			if (~this.IsFixedPoint)
				% Oblicz i zastosuj œredni¹ si³ê wypadkow¹
				forceBodyOne = this.AccelerationVector * this.CalculateMass();
				forceBodyTwo = gravitationalBody.AccelerationVector * gravitationalBody.CalculateMass();
				
				this.AccelerationVector = (forceBodyOne + forceBodyTwo) / this.CalculateMass();
				
				forceBodyOne = this.VelocityVector * this.CalculateMass();
				forceBodyTwo = gravitationalBody.VelocityVector * gravitationalBody.CalculateMass();
				
				this.VelocityVector = (forceBodyOne + forceBodyTwo) / this.CalculateMass();
			end
			
			
			%   KILL -  Zabija inne cia³a w symulacji
			gravitationalBody.Kill();
		end
		
		function Kill(this)
			%   KILL -  Zabija cia³o, usuwaj¹c je z symulacji.
			%	KILL(this) ustawia jego flage 
		
			
			this.IsAlive = false;
			delete(this.GraphicalObject);
		end
		
		function Draw(this, graphAxes)
			%   RYSUJ (Rysuje cia³o w dostarczonych zakresaach osi.)
			%	DRAW(this, graphAxes)  Rysuje okr¹g³¹ reprezentacjê tego cia³a
			
			xpos = this.XY(1) - this.Radius;
			ypos = this.XY(2) - this.Radius;
			side = this.Radius * 2;
			
			delete(this.GraphicalObject);
			
			this.GraphicalObject = rectangle(...
					'Position', [xpos, ypos, side, side], ...
					'Curvature', [1, 1], ...
					'FaceColor', this.RGB);
		end
    end
end
