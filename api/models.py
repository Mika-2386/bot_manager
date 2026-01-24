from django.db import models

class Bot(models.Model):
    name = models.CharField(max_length=100)
    token = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name

class Scenario(models.Model):
    bot = models.ForeignKey(Bot, related_name='scenarios', on_delete=models.CASCADE)
    name = models.CharField(max_length=100)
    description = models.TextField(blank=True)
    data = models.JSONField()
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name

class Step(models.Model):
    scenario = models.ForeignKey(Scenario, related_name='steps', on_delete=models.CASCADE)
    order = models.IntegerField()
    prompt = models.TextField()
    response_template = models.TextField(blank=True)

    class Meta:
        ordering = ['order']

    def __str__(self):
        return f"Step {self.order} of {self.scenario.name}"