from scipy.optimize import least_squares
import numpy as np
import pandas as pd

#using coefficients to calculate cornering force
def pacejka(P_noCamber, P_camber, L, FZ, IA, alpha):
    #alpha is slip angle
    #P = [250, 1.4, 2.4, -0.25, 3, -0.1, -1.5, 0, 0, -30.5, 1.15, 1, 0, 0, -0.128, 0, 0, 0, 1.43];
    #L = [1, 1, 1, 1, 1, 1, 1, 1];
    dfz = (FZ - 250) / 250
    Svy = FZ * (0 + 0*dfz + (0 + P_camber[6]*dfz)*IA) * L[7] * L[4]
    Ey = (P_noCamber[4] + P_noCamber[5]*dfz) * (1 - (0 + 0*IA) * np.sign(alpha)) * L[6]
    Shy = (0 + 0*dfz + P_camber[3]*IA) * L[5]
    alphaY = alpha + Shy
    Cy = P_noCamber[1] * L[1]
    Dy = FZ * (P_noCamber[2] + P_noCamber[3]*dfz) * (1 - P_camber[0]*IA**2) * L[0]
    x1 = 2 * np.arctan(FZ / (P_noCamber[9]*250*L[2]))
    x2 = P_noCamber[8]*250*np.sin(x1) * (1 - P_camber[1]*np.abs(IA)) * L[3] * L[4]
    By = x2 / (Cy * Dy)
    x3 = By * alphaY
    FY = Dy * np.sin(Cy * np.arctan(x3 - Ey * (x3 - np.arctan(x3)))) + Svy

    return FY

#make coefficients not based on camber as close to each other as possible
def diff_noCamber(P_noCamber, P_camber, L, FZ, IA, alpha, Fy_measured):
    FY_calculated = pacejka(P_noCamber, P_camber, L, FZ, IA, alpha)
    FY_diff_total = 0
    for i in range(len(FY_measured)):
        FY_diff_total += abs(FY_calculated[i] - FY_measured[i])
    return FY_diff_total / len(FY_measured)
    #return abs(Fy_measured - pacejka(P_noCamber, P_camber, L, FZ, IA, alpha))

#make coefficients based on camber as close as possible
def diff_camber(P_camber, P_noCamber, L, FZ, IA, alpha, Fy_measured):
    FY_calculated = pacejka(P_noCamber, P_camber, L, FZ, IA, alpha)
    FY_diff_total = 0
    for i in range(len(FY_measured)):
        FY_diff_total += abs(FY_calculated[i] - FY_measured[i])
    return FY_diff_total / len(FY_measured)
    #return abs(Fy_measured - pacejka(P_noCamber, P_camber, L, FZ, IA, alpha))

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
df = pd.read_csv("C:/Users/ajsau/Downloads/R20_FZ_250_filtered.csv")
P = np.array([250, 1.4, 2.4, -0.25, 3, -0.1, -1.5, 0, 0, -30.5, 1.15, 1, 0, 0, -0.128, 0, 0, 0, 1.43])
P_noCamber = np.array([P[0], P[1], P[2], P[3], P[5], P[6], P[7], P[8], P[9], P[10], P[12], P[15]])
P_camber = np.array([P[4], P[11], P[13], P[14], P[16], P[17], P[18]])
L = np.array([1, 1, 1, 1, 1, 1, 1, 1])
FZ = df["NormalForce"]
IA = df["InclinationAngle"]
alpha = df["SlipAngle"]
FY_measured = df["LateralForce"]

#estimate the noCamber things first
result_noCamber_init = least_squares(diff_noCamber, P_noCamber, args=(P_camber, L, FZ, IA, alpha, FY_measured))
#now change the coefficient - this result is the changed P_nocamber values
P_noCamber = result_noCamber_init.x
P = edit_P_with_no_Camber(P, P_noCamber)
remove_small_data(P)
print(f"Updated coefficients after optimization based on the values with no camber: {P}")
find_non_zeros(P)

#estimate the camber things 
result_camber_init = least_squares(diff_camber, P_camber, args=(P_noCamber, L, FZ, IA, alpha, FY_measured))
#change the coefficient array
P_camber = result_camber_init.x
P = edit_P_with_camber(P, P_camber)
remove_small_data(P)
print(f"Updated coefficients after optimization based on the values with camber: {P}")
find_non_zeros(P)

#estimate the noCamber again now that the camber coeffficients are edited
result_camber_final = least_squares(diff_noCamber, P_noCamber, args=(P_camber, L, FZ, IA, alpha, FY_measured))
#now change the coefficient - this result is the changed P_nocamber values
P_noCamber = result_noCamber_init.x
P = edit_P_with_no_Camber(P, P_noCamber)
remove_small_data(P)
print(f"Final coefficients after removing insignificant data: {P}")
print(f"Final cost: {result_noCamber_init.cost}")
find_non_zeros(P)