from scipy.optimize import least_squares
import numpy as np
import pandas as pd

#using coefficients to calculate cornering force
def pacejka(P, L, FZ, IA, alpha):
    #alpha is slip angle
    #P = [250, 1.4, 2.4, -0.25, 3, -0.1, -1.5, 0, 0, -30.5, 1.15, 1, 0, 0, -0.128, 0, 0, 0, 1.43];
    #L = [1, 1, 1, 1, 1, 1, 1, 1];
    dfz = (FZ - P[0]) / P[0]
    Svy = FZ * (0 + 0*dfz + (0 + P[18]*dfz)*IA) * L[7] * L[4]
    Ey = (P[5] + P[6]*dfz) * (1 - (0 + 0*IA) * np.sign(alpha)) * L[6]
    Shy = (0 + 0*dfz + P[14]*IA) * L[5]
    alphaY = alpha + Shy
    Cy = P[1] * L[1]
    Dy = FZ * (P[2] + P[3]*dfz) * (1 - P[4]*IA**2) * L[0]
    x1 = 2 * np.arctan(FZ / (P[10]*P[0]*L[2]))
    x2 = P[9]*P[0]*np.sin(x1) * (1 - P[11]*np.abs(IA)) * L[3] * L[4]
    By = x2 / (Cy * Dy)
    x3 = By * alphaY
    FY = Dy * np.sin(Cy * np.arctan(x3 - Ey * (x3 - np.arctan(x3)))) + Svy

    return FY

#make them as close to each other as possible
def diff(P, L, FZ, IA, alpha, Ty_measured):
    return pacejka(P, L, FZ, IA, alpha) - Ty_measured
# 15 16 17
#load the data
df = pd.read_csv("C:/Users/ajsau/Documents/formula/corneringSim/cornering-simulation/LCO_infoTable.csv")
P = np.array([250, 1.4, 2.4, -0.25, 3, -0.1, -1.5, 0, 0, -30.5, 1.15, 1, 0, 0, -0.128, 0, 0, 0, 1.43])
P_noCamber = np.array([P[0], P[1], P[2], P[3], P[5], P[6], P[7], P[8], P[9], P[10], P[12], P[15]])
P_camber = np.array([P[4], P[11], P[13], P[14], P[16], P[17], P[18]])
L = np.array([1, 1, 1, 1, 1, 1, 1, 1])
FZ = df["NormalForce"]
IA = df["InclinationAngle"]
alpha = df["SlipAngle"]
FY_measured = df["CorneringForceMeasured"]

result = least_squares(diff, P, args=(L, FZ, IA, alpha, FY_measured))

print(result.x)