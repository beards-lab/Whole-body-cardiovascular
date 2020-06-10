# Post-process the output of GenOpt sensitivity analysis (OutputListingMain.txt)
import matplotlib.pyplot as plt

# read the SA params with default values, generated by manipulate_dsin.py
params_def = {}
with open(r'..\CodeGen\init_params_default_vals.csv') as file:
    for line in file.readlines():
        cols = line.split(',')
        params_def[cols[0]] = cols[1]


with open('OutputListingMain.txt') as file:
    lines = file.readlines()



param_names = {}
data_begin = False
sensitivity_list = []
for line in lines:

    # prepare the header
    if not data_begin and line.startswith('Simulation Number'):
        # Simulation Number	Main Iteration	Step Number	f(x)	settings.phi0	settings.height	settings...
        cols = line.rstrip('\n').split('\t')
        for i in range(len(cols)):
            param_names[i] = cols[i]
        data_begin = True
        continue

    if data_begin:
        # find the parameters than are varied
        cols = line.rstrip('\n').split('\t')
        # first 4 cols are runs and f(x) and last one is comment
        for col_num in range(4, len(cols)-1):
            param_name = param_names[col_num]
            param_short_name = param_name[9:] if param_name.startswith('settings.') else param_name
            param_def_val = float(params_def[param_name])
            param_cur_val = float(cols[col_num])
            cost = float(cols[3])
            run = int(cols[0])
            # absolute values to counter negative parameters
            # 1/1000 tolerance of numeric precision
            if abs(param_cur_val) > abs(param_def_val)*1.001:
                sa_tup = (param_short_name + '+', cost, param_cur_val, run)
                sensitivity_list.append(sa_tup)
                # print(param_name + " is bigger")

            elif abs(param_cur_val) < abs(param_def_val)/1.001:
                sa_tup = (param_short_name + '-', cost, param_cur_val, run)
                sensitivity_list.append(sa_tup)
                # print(param_name + " is smaller")
            else:
                # this parameter has not been changed
                pass

sensitivity_list.sort(key = lambda x: x[1])

def printLine(line:tuple):
    # line = (name, cost, param_cur_val, run)
    printline = '%.4f, %s, %d' % (line[1], line[0], line[3])
    print(printline)
    return printline


lines = '\n'.join(list(map(printLine, sensitivity_list)))

with open('sa_output.csv', 'w') as file:
    file.write('Cost, param, run')
    file.writelines(lines)

num_to_plot = 30
plotlist = sensitivity_list[:num_to_plot]
plotlist.reverse()
heights = list((x[1] for x in plotlist))
labels = list((x[0] for x in plotlist))
dpi = 100
plt.figure(figsize = [800/dpi, 800/dpi], dpi=dpi, )
plt.barh(range(len(heights)), heights, tick_label = labels)
plt.subplots_adjust(left=0.4)
plt.xlabel('Total cost')
plt.savefig('sa_result.png')
plt.show()
plt.figure
# print('Sensitivity>', sensitivity_list)
pass

        