from flask import Flask, request, jsonify
from flask_compress import Compress
from flask_cors import cross_origin
from scipy.optimize import minimize, Bounds, dual_annealing, least_squares
import numpy as np

app = Flask(__name__)

Compress(app)

@app.route("/")
def hello_world():
    return "<p>Hello, World!</p>"

def normalizeCmyk(cmyk) -> np.ndarray:
    if not isinstance(cmyk, np.ndarray):
        cmyk = np.array(cmyk)
    cmyk = cmyk.clip(min=0, max=1)
    black = np.min(cmyk[:3])
    cmyk[:3] -= black
    cmyk[3] += black
    return cmyk.clip(min=0, max=1)

@app.route("/solve_eq", methods=["POST"])
@cross_origin()
def solve_eq():
    cmyk_cpnts = request.json['cmyk_cpnts']
    cmyk_A = normalizeCmyk(request.json['cmyk_A'])
    X = np.array([normalizeCmyk(cpnt) for cpnt in cmyk_cpnts]).transpose()

    def calc_mixed(p):
        mixed = normalizeCmyk(X @ p)
        return mixed.clip(min=0, max=1)

    def loss(p):
        res = calc_mixed(p) - cmyk_A
        return (res ** 2).sum()

    r = None
    for _ in range(1):
        p0 = np.random.uniform(0, 1, len(cmyk_cpnts))
        new_r = dual_annealing(loss, bounds=[(0,1)]*len(p0))
        # new_r = least_squares(loss, x0=p0, bounds=(0, 1))
        #new_r = minimize(loss, p0, bounds=Bounds(0, 1))
        if r is None:
            r = new_r
        elif new_r.fun < r.fun:
            r = new_r

    return jsonify({
        "r.success": r.success,
        "r.fun": float(r.fun),
        "r.x": list(r.x.astype("float")),
        "mixed": list(calc_mixed(r.x).astype('float'))
    })
    

if __name__ == '__main__':
    app.run(host='0.0.0.0',port=9000)