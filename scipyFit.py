from scipy.optimize import least_squares
import numpy as np
import pandas as pd
import math
import matplotlib.pyplot as plt

#using coefficients to calculate cornering force

def pacejka(P, L, IA, alpha, FZ):
    #P = [250, 1.4, 2.4, -0.25, 3, -0.1, -1.5, 0, 0, -30.5, 1.15, 1, 0, 0, -0.128, 0, 0, 0, 1.43];
    #L = [1, 1, 1, 1, 1, 1, 1, 1];
    dfz = (FZ - P[0]) / P[0]
    Svy = FZ * (P[15] + P[16] * dfz + (P[17] + P[18] * dfz) * IA) * L[7] * L[4]
    Ey = (P[5] + P[6] * dfz) * (1 - (P[7] + P[8] * IA) * np.sign(alpha)) * L[6]
    Shy = (P[12] + P[13] * dfz + P[14] * IA) * L[5]
    alphaY = alpha + Shy
    Cy = P[1] * L[1]
    Dy = FZ * (P[2] + P[3] * dfz) * (1 - P[4] * IA**2) * L[0]
    x1 = 2 * np.arctan(FZ / (P[10] * P[0] * L[2]))
    x2 = P[9] * P[0] * np.sin(x1) * (1 - P[11] * np.abs(IA)) * L[3] * L[4]
    By = x2 / (Cy * Dy)

    x3 = By * alphaY
    FY = Dy * np.sin(Cy * np.arctan(x3 - Ey * (x3 - np.arctan(x3)))) + Svy

    return FY

'''
#graph the resulting data to see how it matches up
def graphResult(P, L):
    #grab data
    #calculate FY
    FY_calculated = pacejka(P, L, IA, alpha, FZ)
    plt.scatter(alpha, FY_measured, color="Blue")
    plt.scatter(alpha, FY_calculated, color="Red")
    plt.show()
'''
def pacejka250(P250, P, L, IA, alpha, FZ, FY_measured):
    dfz = (FZ - P[0]) / P[0]
    Svy = FZ * (P[15] + P[16] * dfz + (P[17] + P[18] * dfz) * IA) * L[7] * L[4]
    Ey = (P250[2] + P[6] * dfz) * (1 - (P[7] + P[8] * IA) * np.sign(alpha)) * L[6]
    Shy = (0 + P[13] * dfz + P[14] * IA) * L[5]
    alphaY = alpha + Shy
    Cy = P250[0] * L[1]
    Dy = FZ * (P250[1] + P[3] * dfz) * (1 - P[4] * IA**2) * L[0]
    x1 = 2 * np.arctan(FZ / (P[10] * P[0] * L[2]))
    x2 = P[9] * P[0] * np.sin(x1) * (1 - P[11] * np.abs(IA)) * L[3] * L[4]
    By = x2 / (Cy * Dy)
    x3 = By * alphaY
    FY_calculated = Dy * np.sin(Cy * np.arctan(x3 - Ey * (x3 - np.arctan(x3)))) + Svy
    return rmse(FY_measured, FY_calculated)

def pacejka_no_camber(P_no_camber, P, L, IA, alpha, FZ, FY_measured):
    dfz = (FZ - P[0]) / P[0]
    Svy = FZ * (P[15] + P[16] * dfz + (P[17] + P[18] * dfz) * IA) * L[7] * L[4]
    Ey = (P[5] + P[6] * dfz) * (1 - (P[7] + P[8] * IA) * np.sign(alpha)) * L[6]
    Shy = (P[12] + P[13] * dfz + P[14] * IA) * L[5]
    alphaY = alpha + Shy
    Cy = P[1] * L[1]
    Dy = FZ * (P[2] + P_no_camber[0] * dfz) * (1 - P[4] * IA**2) * L[0]
    x1 = 2 * np.arctan(FZ / (P_no_camber[2] * P[0] * L[2]))
    x2 = P_no_camber[1] * P[0] * np.sin(x1) * (1 - P_no_camber[3] * np.abs(IA)) * L[3] * L[4]
    By = x2 / (Cy * Dy)
    x3 = By * alphaY
    FY_calculated = Dy * np.sin(Cy * np.arctan(x3 - Ey * (x3 - np.arctan(x3)))) + Svy
    return rmse(FY_measured, FY_calculated)

def rmse(FY_measured, FY_calculated):
    #calculate rmse_value
    sumDifference = 0
    n = len(FY_measured)
    for i in range(n):
        sumDifference += (FY_measured[i] - FY_calculated[i])**2
    radicand = sumDifference/n
    rmse_value = math.sqrt(radicand)
    return rmse_value

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

def add250_coeff(P, P250):
    P[1] = P250[0]
    P[2] = P250[1]
    P[5] = P250[2]
    P[12] = P250[3]
    return P

def add_no_camber_coeff(P, P_no_camber):
    P[3] = P_no_camber[0]
    P[9] = P_no_camber[1]
    P[10] = P_no_camber[2]
    P[11] = P_no_camber[3]
    return P

P = np.array([250, 1.4, 2.4, -0.25, 3, -0.1, -1.5, 0, 0, -30.5, 1.15, 1, 0, 0, -0.128, 0, 0, 0, 1.43])
print(f"Intial guess at coefficients: {P}")

#load the data
df250 = pd.read_csv("C:/Users/ajsau/Downloads/R20_FZ_250_filtered.csv")
P250 = np.array([P[1], P[2], P[5], P[12]])
L = np.array([1, 1, 1, 1, 1, 1, 1, 1])
FZ250 = df250["NormalForce"]
IA250 = df250["InclinationAngle"]
alpha250 = df250["SlipAngle"]
FY_measured250 = df250["LateralForce"]
result_250 = least_squares(pacejka250, P250, args=(P, L, IA250, alpha250, FZ250, FY_measured250))
P = add250_coeff(P, result_250.x)
print(f"Calculated Coefficients after 250 load optimization: {P}")
find_non_zeros(P)

df_no_camber = pd.read_csv("C:/Users/ajsau/Downloads/R20_combined_filtered.csv")
FZ_no_camber = df_no_camber["NormalForce"]
IA_no_camber = df_no_camber["InclinationAngle"]
alpha_no_camber = df_no_camber["SlipAngle"]
FY_measured_no_camber = df_no_camber["LateralForce"]
P_no_camber = np.array([P[3], P[9], P[10], P[11]])
result_no_camber = least_squares(pacejka_no_camber, P_no_camber, args=(P, L, IA_no_camber, alpha_no_camber, FZ_no_camber, FY_measured_no_camber))
P = add_no_camber_coeff(P, result_no_camber.x)
print(f"Calculated Coefficients after all load optimization: {P}")
find_non_zeros(P)

#graph the result to view accuracy
#graphResult(P)