from flask import Flask, request, jsonify
from flask_compress import Compress
from flask_cors import cross_origin
from scipy.optimize import minimize, Bounds, dual_annealing
import numpy as np

app = Flask(__name__)

Compress(app)

@app.route("/")
def hello_world():
    return "<p>Hello, World!</p>"

@app.route("/solve_eq", methods=["POST"])
@cross_origin()
def solve_eq():
    cmyk_cpnts = request.json['cmyk_cpnts']
    cmyk_A = request.json['cmyk_A']
    X = np.array(cmyk_cpnts).transpose()
    def loss(p):
        mixed = X @ p
        mixed = mixed.clip(min=0, max=1)
        res = (mixed - cmyk_A)
        return (res ** 2).sum()

    r = None
    for _ in range(1):
        p0 = np.random.uniform(0, 1, len(cmyk_cpnts))
        new_r = dual_annealing(loss, bounds=[(0,1)]*len(p0))
        #new_r = minimize(loss, p0, bounds=Bounds(0, 1))
        if r is None:
            r = new_r
        elif new_r.fun < r.fun:
            r = new_r

    return jsonify({
        "r.success": r.success,
        "r.fun": float(r.fun),
        "r.x": list(r.x.astype("float")),
        "mixed": list((X @ r.x).clip(min=0, max=1).astype('float'))
    })
    

if __name__ == '__main__':
    app.run(host='0.0.0.0',port=9000)