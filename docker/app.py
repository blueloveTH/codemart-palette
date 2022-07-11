from flask import Flask, request, jsonify
from flask_compress import Compress
from flask_cors import cross_origin
from scipy.optimize import minimize, dual_annealing, shgo
import numpy as np

app = Flask(__name__, static_folder='web', static_url_path='')

app.config['COMPRESS_MIMETYPES'] = ['text/html', 'text/css', 'text/xml', 
                                    'application/json',
                                    'application/javascript', 'font/ttf', 'font/otf', 'application/octet-stream']

Compress(app)

@app.route("/")
def index():
    return app.send_static_file('index.html')

def normalizeCmyk(cmyk) -> np.ndarray:
    if not isinstance(cmyk, np.ndarray):
        cmyk = np.array(cmyk)
    cmyk = cmyk.clip(min=0, max=1)
    black = np.min(cmyk[:3])
    cmyk += np.array([-black, -black, -black, black])
    return cmyk.clip(min=0, max=1)

@app.route("/solve_eq", methods=["POST"])
@cross_origin()
def solve_eq():
    cmyk_cpnts = request.json['cmyk_cpnts']
    cmyk_A = normalizeCmyk(request.json['cmyk_A'])
    X = np.array([normalizeCmyk(cpnt) for cpnt in cmyk_cpnts]).transpose()

    def calc_mixed(p):
        p = p / (p.sum() + 1e-3)
        return normalizeCmyk(X @ p)

    def loss(p):
        res = calc_mixed(p) - cmyk_A
        return (res ** 2).sum()

    algo = request.json.get("algo", "dual_annealing")
    p0 = np.random.uniform(0, 1, len(cmyk_cpnts))
    bounds = [(0,1)]*len(cmyk_cpnts)

    if algo == 'dual_annealing':
        r = dual_annealing(loss, bounds=bounds, maxiter=600)
    elif algo == 'local':
        r = minimize(loss, p0, bounds=bounds)
    elif algo == 'shgo':
        r = shgo(loss, bounds=bounds)

    r.x = r.x / (r.x.sum() + 1e-3)

    return jsonify({
        "r.success": r.success,
        "r.fun": float(r.fun),
        "r.x": list(r.x.astype("float")),
        "mixed": list(calc_mixed(r.x).astype('float'))
    })
    

if __name__ == '__main__':
    app.run(host='0.0.0.0',port=9000)