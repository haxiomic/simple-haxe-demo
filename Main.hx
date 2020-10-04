import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.Browser.*;

class Main {

	static function main() {
		trace('Entry point!');
		new Main();
	}

	final canvas: CanvasElement;
	final ctx2d: CanvasRenderingContext2D;

	// settings
	var gravity = 0;
	var wallDampening = 0.9;
	var wallFriction = 0.9;
	var mouseAttraction = 50;
	var airDampening = 0.2;

	// state
	var mouseActive: Bool = false;
	var mouseX: Float = null;
	var mouseY: Float = null;

	var balls = new Array<Ball>();

	function new() {
		canvas = document.createCanvasElement();
		document.body.appendChild(canvas);
		canvas.width = 800;
		canvas.height = 600;

		ctx2d = canvas.getContext2d();

		window.requestAnimationFrame(frameLoop);
		canvas.addEventListener('mousemove', (e) -> {
			mouseActive = true;
			mouseX = e.clientX;
			mouseY = e.clientY;
		});
		canvas.addEventListener('mouseleave', (e) -> {
			mouseActive = false;
		});

		// create a bunch of balls
		var w = 20;
		var h = 20;
		for (i in 0...w) {
			for (j in 0...h) {
				var u = i / (w - 1);
				var v = j / (h - 1);
				var ball = new Ball(u * canvas.width, v * canvas.height);
				ball.r = u;
				ball.g = v;
				ball.b = 1.0;
				balls.push(ball);
			}
		}
	}

	function frameLoop(t_ms: Float) {
		var dt_s = 1/60;

		// clear canvas
		ctx2d.clearRect(0, 0, canvas.width, canvas.height);

		// for (ball in balls) {
		for (i in 0...balls.length) {
			var ball = balls[i];
			ball.vx += -airDampening * ball.vx * dt_s;
			ball.vy += -airDampening * ball.vy * dt_s;

			// gravity
			ball.vy += gravity * dt_s;

			// attraction to mouse
			if (mouseActive) {
				var dx = mouseX - ball.x;
				var dy = mouseY - ball.y;
				var dSq = dx*dx + dy*dy;
				var d = Math.sqrt(dSq);

				// var f = mouseAttraction * d;
				var f = -300000 / (dSq + 50);

				ball.vx += (f * dx / d) * dt_s;
				ball.vy += (f * dy / d) * dt_s;
			}

			// interaction with other balls
			for (j in (i + 1)...balls.length) {
				var ball2 = balls[j];
				var dx = ball2.x - ball.x;
				var dy = ball2.y - ball.y;
				var dSq = dx*dx + dy*dy;
				var d = Math.sqrt(dSq);

				var f = 0.0;
				// close-range repulsion
				f += -1000000.0 / (Math.pow(d, 4) + 100);
				f += 2000.0 / (dSq + 100);

				ball.vx += (f * dx / d) * dt_s;
				ball.vy += (f * dy / d) * dt_s;
				ball2.vx -= (f * dx / d) * dt_s;
				ball2.vy -= (f * dy / d) * dt_s;
			}

			ball.x += ball.vx * dt_s;
			ball.y += ball.vy * dt_s;

			// collide with walls
			// right
			var dx = ball.x - canvas.width;
			if (dx > 0) {
				ball.x = canvas.width - dx;
				ball.vx *= -wallDampening;
				ball.vy *= wallFriction;
			}
			// left
			var dx = ball.x;
			if (dx < 0) {
				ball.x = - dx;
				ball.vx *= -wallDampening;
				ball.vy *= wallFriction;
			}
			// bottom
			var dy = ball.y - canvas.height;
			if (dy > 0) {
				ball.y = canvas.height - dy;
				ball.vy *= -wallDampening;
				ball.vx *= wallFriction;
			}
			// top
			var dy = ball.y;
			if (dy < 0) {
				ball.y = - dy;
				ball.vy *= -wallDampening;
				ball.vx *= wallFriction;
			}

			ctx2d.beginPath();
			ctx2d.arc(ball.x, ball.y, 5, 0, 2 * Math.PI);
			// ctx2d.fillStyle = 'rgba(${ball.r * 255}, ${ball.g * 255}, ${ball.b * 255}, 1.)';
			// ctx2d.fillStyle = 'rgba(${ball.r * 255}, ${ball.g * 255}, ${ball.b * 255}, 1.)';
			ctx2d.fillStyle = 'rgba(${ball.r * 255}, ${ball.g * 255}, ${ball.b * 255}, 1.0)';
			ctx2d.fill();
		}


		window.requestAnimationFrame(frameLoop);
	}

}

class Ball {

	public var x: Float = 0.;
	public var y: Float = 0.;
	public var vx: Float = 0.;
	public var vy: Float = 0.;

	public var r: Float = 0;
	public var g: Float = 0;
	public var b: Float = 0;

	public function new(x: Float, y: Float) {
		this.x = x;
		this.y = y;
	}

}