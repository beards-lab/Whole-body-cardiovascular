import scipy.io as skipy
import fun_lib
import numpy
from statistics import mean
import  matplotlib.pyplot as plt
# import DyMat
# from matplotlib import pyplot as plt

mmHg2SI = 133.32
ml2SI = 1e-6
lpm2SI = 1e-3/60

def getObjectives(vars_set):

    fun_lib.checkSimulationLength(vars_set['time'][-1],150, penalty = 1e10)

    objectives = []
    o = fun_lib.ObjectiveVar('Error', value = max(vars_set['err']), costFunctionType=fun_lib.CostFunctionType.DistanceFromZero)
    objectives.append(o)

    return objectives
