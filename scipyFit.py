from scipy.optimize import least_squares
import numpy as np
import pandas as pd
import math

#using coefficients to calculate cornering force
def pacejka(P):
    #P = [250, 1.4, 2.4, -0.25, 3, -0.1, -1.5, 0, 0, -30.5, 1.15, 1, 0, 0, -0.128, 0, 0, 0, 1.43];
    #L = [1, 1, 1, 1, 1, 1, 1, 1];
    dfz = (FZ - P[0]) / P[0]
    Svy = FZ * (P[15] + P[16] * dfz + (P[17] + P[18] * dfz) * IA)
    Ey = (P[5] + P[6] * dfz) * (1 - (P[7] + P[8] * IA) * np.sign(alpha))
    Shy = (P[12] + P[13] * dfz + P[14] * IA)
    alphaY = alpha + Shy
    Cy = P[1]
    Dy = FZ * (P[2] + P[3] * dfz) * (1 - P[4] * IA**2)
    x1 = 2 * np.arctan(FZ / (P[10] * P[0]))
    x2 = P[9] * P[0] * np.sin(x1) * (1 - P[11] * np.abs(IA))
    By = x2 / (Cy * Dy)

    x3 = By * alphaY
    FY = Dy * np.sin(Cy * np.arctan(x3 - Ey * (x3 - np.arctan(x3)))) + Svy

    return FY

def rmse(FY_measured):
    #calculate 
    sumDifference = 0
    n = len(FY_measured)
    for i in range(n):
        sumDifference += (FY_measured[i] - FY_calculated[i])
    radicand = sumDifference/n
    rmse_value = math.sqrt(radicand)
    return rmse_value

#update P to have the new coefficients not based on camber
def edit_P_with_no_Camber(P, P_noCamber):
    P[0] = P_noCamber[0]
    P[1] = P_noCamber[1]
    P[2] = P_noCamber[2]
    P[3] = P_noCamber[3]
    P[5] = P_noCamber[4]
    P[6] = P_noCamber[5]
    P[7] = P_noCamber[6]
    P[8] = P_noCamber[7]
    P[9] = P_noCamber[8]
    P[10] = P_noCamber[9]
    P[12] = P_noCamber[10]
    P[15] = P_noCamber[11]
    return P

#update P to have the new coefficients based on camber
def edit_P_with_camber(P, P_camber):
    P[4] = P_camber[0]
    P[11] = P_camber[1]
    P[13] = P_camber[2]
    P[14] = P_camber[3]
    P[16] = P_camber[4]
    P[17] = P_camber[5]
    P[18] = P_camber[6]
    return P

#finds coefficients that should be zero but weren't calculated to be zero
def find_non_zeros(P):
    if P[7] != 0:
        print(f"Item P[7] should be 0 but it is actually {P[7]}")
    if P[8] != 0:
        print(f"Item P[8] should be 0 but it is actually {P[8]}")
    if P[12] != 0:
        print(f"Item P[12] should be 0 but it is actually {P[12]}")
    if P[13] != 0:
        print(f"Item P[13] should be 0 but it is actually {P[13]}")
    if P[15] != 0:
        print(f"Item P[15] should be 0 but it is actually {P[15]}")
    if P[16] != 0:
        print(f"Item P[16] should be 0 but it is actually {P[16]}")
    if P[17] != 0:
        print(f"Item P[17] should be 0 but it is actually {P[17]}")

#don't know if this is needed, but some datapoints seem to be very insignificant
#removes any datapoints that seem like they should be insignificant
def remove_small_data(P):
    for i in range(len(P)):
        if abs(P[i]) < 1e-10:
            P[i] = 0

#load the data
df250 = pd.read_csv("C:/Users/ajsau/Downloads/R20_FZ_250_filtered.csv")
P = np.array([250, 1.4, 2.4, -0.25, 3, -0.1, -1.5, 0, 0, -30.5, 1.15, 1, 0, 0, -0.128, 0, 0, 0, 1.43])
L = np.array([1, 1, 1, 1, 1, 1, 1, 1])
FZ = df250["NormalForce"]
IA250 = df250["InclinationAngle"]
alpha250 = df250["SlipAngle"]
FY_measured250 = df250["LateralForce"]