import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.Browser.*;

import VectorMath;

final canvas: CanvasElement = document.createCanvasElement();
final ctx2d: CanvasRenderingContext2D = canvas.getContext2d();

// settings
var gravity = 0.0;
var wallDampening = 0.9;
var wallFriction = 0.9;
var mouseAttraction = 300000;
var airDampening = 0.2;

// state
var mouseActive: Bool = false;
var mousePos = vec2(0);

var balls = new Array<Ball>();

function main() {
	document.body.appendChild(canvas);
	canvas.width = 800;
	canvas.height = 600;

	window.requestAnimationFrame(frameLoop);
	canvas.addEventListener('mousemove', (e) -> {
		mouseActive = true;
		mousePos.x = e.clientX;
		mousePos.y = e.clientY;
	});
	canvas.addEventListener('mouseleave', (e) -> {
		mouseActive = false;
	});

	// create a bunch of balls
	var w = 20;
	var h = 20;
	for (i in 0...w) {
		for (j in 0...h) {
			var uv = vec2(i / (w - 1), j / (h - 1));
			var ball = new Ball(uv * vec2(canvas.width, canvas.height));
			var rgb = vec3(uv, 1.);
			ball.fillStyle = 'rgba(${rgb.x * 255}, ${rgb.y * 255}, ${rgb.z * 255}, 1.0)';
			balls.push(ball);
		}
	}
}

function frameLoop(t_ms: Float) {
	var dt_s = 1/60;

	// clear canvas
	ctx2d.clearRect(0, 0, canvas.width, canvas.height);

	// iterate balls, apply forces and draw
	for (i in 0...balls.length) {
		var ball = balls[i];

		ball.vel += -airDampening * ball.vel * dt_s;

		// gravity
		ball.vel.y += gravity * dt_s;

		// attraction to mouse
		if (mouseActive) {
			var delta = mousePos - ball.pos;
			var distance = length(delta);
			var deltaNorm = delta / distance;

			var f = -mouseAttraction / (distance * distance + 50);

			ball.vel += f * deltaNorm * dt_s;
		}

		// interaction with other balls
		for (j in (i + 1)...balls.length) {
			var ball2 = balls[j];
			var delta = ball2.pos - ball.pos;
			var distance = length(delta);
			var deltaNorm = delta / distance;

			var f = 0.0;
			// close-range repulsion
			f += -1000000.0 / (Math.pow(distance, 4) + 100);
			// far range attraction
			f += 2000.0 / (distance*distance + 100);

			ball.vel += f * deltaNorm * dt_s;
			ball2.vel -= f * deltaNorm * dt_s;
		}

		ball.pos += ball.vel * dt_s;

		// collide with walls
		// right
		var canvasSize = vec2(canvas.width, canvas.height);
		var wallInteraction = vec2(-wallDampening, wallFriction);
		var delta = ball.pos - canvasSize;

		// right
		if (delta.x > 0) {
			ball.pos.x = canvasSize.x - delta.x;
			ball.vel *= wallInteraction;
		}
		// bottom
		if (delta.y > 0) {
			ball.pos.y = canvasSize.y - delta.y;
			ball.vel *= wallInteraction.yx;
		}
		// left
		if (ball.pos.x < 0) {
			ball.pos.x = -ball.pos.x;
			ball.vel *= wallInteraction;
		}
		// top
		if (ball.pos.y < 0) {
			ball.pos.y = -ball.pos.y;
			ball.vel *= wallInteraction.yx;
		}

		// draw ball
		ctx2d.beginPath();
		ctx2d.arc(ball.pos.x, ball.pos.y, 5, 0, 2 * Math.PI);
		ctx2d.fillStyle = ball.fillStyle;
		ctx2d.fill();
	}

	window.requestAnimationFrame(frameLoop);
}

class Ball {

	public final pos = vec2(0);
	public final vel = vec2(0);
	public var fillStyle: String;

	public function new(pos: Vec2) {
		this.pos.copyFrom(pos);
	}

}