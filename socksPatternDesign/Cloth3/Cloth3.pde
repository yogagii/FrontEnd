import traer.physics.*;

ParticleSystem physics;

Particle[][] particles;
Particle[] anchors;
Particle anchor;

int screenWidth = 400;
int screenHeight = 400;

int gridSize = 10;
float springStrength = 1.0;
float springDamping = 0.1;
float particleMass = 0.1;
float physicsStep = 0.2;
float bounce = 0.8;

float xBoundsMin = 10.0;
float xBoundsMax = screenWidth - 10.0;
float yBoundsMin = 10.0;
float yBoundsMax = screenHeight - 10.0;

void setup()
{
    size(screenWidth, screenHeight);
    smooth();
    fill(0);
    framerate(60);

    physics = new ParticleSystem(0.2, 0.005);

    particles = new Particle[gridSize][gridSize];

    float gridStepX = (float) ((width / 2) / gridSize);
    float gridStepY = (float) ((height / 2) / gridSize);

    for (int i = 0; i < gridSize; i++)
    {
        for (int j = 0; j < gridSize; j++)
        {
            particles[i][j] = physics.makeParticle(0.1, j * gridStepX + (width / 4), i * gridStepY + 20, 0.0);
            if (j > 0)
            {
                Particle p1 = particles[i][j - 1];
                Particle p2 = particles[i][j];
                physics.makeSpring(p1, p2, springStrength, springDamping, gridStepY);
            }
            if (i > 0)
            {
                Particle p1 = particles[i - 1][j];
                Particle p2 = particles[i][j];
                physics.makeSpring(p1, p2, springStrength, springDamping, gridStepY);
            }
        }
    }

    particles[0][0].makeFixed();
    particles[0][gridSize - 1].makeFixed();

    anchors = new Particle[4];
    anchors[0] = particles[0][0];
    anchors[1] = particles[0][gridSize - 1];
    anchors[2] = particles[gridSize - 1][0];
    anchors[3] = particles[gridSize - 1][gridSize - 1];
}

void draw()
{
    physics.advanceTime(physicsStep);

    if (mousePressed)
    {
        anchor.moveTo(mouseX, mouseY, 0);
        anchor.velocity().clear();
    }

    background(255);

    for (int i = 0; i < gridSize; i++)
    {
        for (int j = 0; j < gridSize; j++)
        {
            Particle p = particles[i][j];
            float px = p.position().x();
            float py = p.position().y();
            float vx = p.velocity().x();
            float vy = p.velocity().y();

            if (px < xBoundsMin)
            {
                vx *= -bounce;
                p.moveTo(xBoundsMin, py, 0);
                p.setVelocity(vx, vy, 0);
            }
            else if (px > xBoundsMax)
            {
                vx *= -bounce;
                p.moveTo(xBoundsMax, py, 0);
                p.setVelocity(vx, vy, 0);
            }
            if (py < yBoundsMin)
            {
                vy *= -bounce;
                p.moveTo(px, yBoundsMin, 0);
                p.setVelocity(vx, vy, 0);
            }
            else if (py > yBoundsMax)
            {
                vy *= -bounce;
                p.moveTo(px, yBoundsMax, 0);
                p.setVelocity(vx, vy, 0);
            }
        }
    }

    for (int i = 0; i < gridSize; i++)
    {
        beginShape( LINE_STRIP );
        curveVertex(particles[i][0].position().x(), particles[i][0].position().y());
        for (int j = 0; j < gridSize; j++)
        {
            curveVertex(particles[i][j].position().x(), particles[i][j].position().y());
        }
        curveVertex(particles[i][gridSize - 1].position().x(), particles[i][gridSize - 1].position().y());
        endShape();
    }
    for (int j = 0; j < gridSize; j++)
    {
        beginShape( LINE_STRIP );
        curveVertex(particles[0][j].position().x(), particles[0][j].position().y());
        for (int i = 0; i < gridSize; i++)
        {
            curveVertex(particles[i][j].position().x(), particles[i][j].position().y());
        }
        curveVertex(particles[gridSize - 1][j].position().x(), particles[gridSize - 1][j].position().y());
        endShape();
    }

}

void mousePressed()
{
    int mx = mouseX;
    int my = mouseY;
    float d = -1.0;

    for (int i = 0; i < gridSize; i++)
    {
        for (int j = 0; j < gridSize; j++)
        {
            float dTemp = distance(mx, my, particles[i][j].position().x(), particles[i][j].position().y());
            if (dTemp < d || d < 0)
            {
                d = dTemp;
                anchor = particles[i][j];
            }
        }
    }
}

void mouseReleased()
{
    if (keyPressed)
    {
        if (key == ' ')
        {
            anchor.makeFixed();
        }
    }
    else
    {
        anchor.makeFree();
    }
    anchor = null;
}

float distance(float x1, float y1, float x2, float y2)
{
    float dx = x2 - x1;
    float dy = y2 - y1;
    return sqrt((dx * dx) + (dy * dy));
}
